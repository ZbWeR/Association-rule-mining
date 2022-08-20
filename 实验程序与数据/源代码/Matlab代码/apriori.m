clear; clc;%运行前请将dataset.xlsx文件移到对应位置

min_sup=input("请输入最小支持度([0,1]的小数，示例：0.4)\n"); % 最小支持度
min_con=input("请输入最小置信度([0,1]的小数，示例：0.9)\n"); % 最小置信度

[num,txt,raw]=xlsread('E:\Desktop\dataset.xlsx');%读取原始数据库，将原始数据库以cell形式储存在raw中
[n,m]=size(raw);%得到raw的行数n,列数m
dataset=raw(2,2:m);%获取raw中每一列对应的商品名称
data=raw(3:n,2:m);%获取raw中的购物数据
data=cell2mat(data);%将cell改为矩阵，才能使用find
[n,m]=size(data);%获取处理后行数和列数
for i=1:n
	x{i}=find(data(i,:)=='T');%求每行购买商品的编号
end

k=0;
while 1
	k=k+1;
	L{k}={};%创建空的元胞数组，作为频繁集
	if k==1
		C{k}=(1:m)';%生成候选集C{k},而且便于后续拼接支持度
	else
		[nL,mL]=size(L{k-1});%获取上一个频繁集行列数
		cnt=0;
		for i=1:nL
			for j=i+1:nL
				tmp=union(L{k-1}(i,:),L{k-1}(j,:));
                %%两集合并集,但若是第i行与第j行没有相同项，那么union就没有删除的，项数会比k大，因此有以下if
                %%判断合并后项集tem长度满不满足下一频繁集长度
				if length(tmp)==k
					cnt=cnt+1;
					C{k}(cnt,1:k)=tmp;% 存入下一候选集
				end
			end
        end
		C{k}=unique(C{k},'rows');%删除重复项
    end
	[nC,mC]=size(C{k}); % 候选集大小
    
	for i=1:nC
		cnt=0;
		for j=1:n
			if all(ismember(C{k}(i,:),x{j}),2)==1 % all函数判断向量是否全为1，参数2表示按行判断
				cnt=cnt+1;
                %%通过ismember将C{k}的第i行数据（每个项集）到编号后的原数据库匹配，成功一次则计数一次，支持度加1
			end
		end
		C_sup{k}(i,1)=cnt;% 将每行候选集对应的支持度保存在新元胞数组第一列
    end
	L{k}=C{k}(C_sup{k}/n>=min_sup,:);%选出满足最小支持度的那一行的编号k，并用这个编号k将C{}中满足的项集赋给L{}
    %%C{k}始终是候选集，L{k}是频繁项集，x{k}是原始数据库
	if isempty(L{k}) % 这次没有找出频繁项集，直接结束
		break;
	end
	if size(L{k},1)==1 % 频繁项集行数为1，下一次无法生成候选集，直接结束
		k=k+1;
		C{k}={};
		L{k}={};
		break
	end
end

fprintf("\n");
fprintf("第%d轮结束，最大频繁项集为:",k); L{k-1}

[nL,mL]=size(L{k-1});%处理最大频繁项集，取行和列序号
rule_count=0;
for p=1:nL %  频繁项序号（行）
	L_last=L{k-1}(p,:); % 取出频繁项
	cnt_ab=0;
	for i=1:n
		if all(ismember(L_last,x{i}),2)==1 % all函数判断向量是否全为1，参数2表示按行判断
			cnt_ab=cnt_ab+1;%整个频繁项的支持度（未除n）
		end
	end
	len=floor(length(L_last)/2);%根据分裂规律，偶数个除2，奇数个减一除2，故直接除2向-∞取整
	for i=1:len
		s=nchoosek(L_last,i); % 从行向量L_last中选i个数的所有组合矩阵
		[ns,ms]=size(s);%组合矩阵大小
		for j=1:ns
			a=s(j,:);%a为某个组合，即前项
			b=setdiff(L_last,a);%取出a后剩下的后项
			[na,ma]=size(a);
			[nb,mb]=size(b);
			cnt_a=0;
			for i=1:na
				for j=1:n
					if all(ismember(a,x{j}),2)==1 % all函数判断向量是否全为1，参数2表示按行判断
						cnt_a=cnt_a+1;%计算前项a的支持度（未除n）
					end
				end
			end
			pab=cnt_ab/cnt_a;%计算前项到后项的置信度
			if pab>=min_con % 关联规则a->b的置信度大于等于最小置信度，是强关联规则
				rule_count=rule_count+1;
				rule(rule_count,1:ma)=a;%将前项a记录在rule的第rule_count行
				rule(rule_count,ma+1:ma+mb)=b;%将后项b记录在同行的后面
				rule(rule_count,ma+mb+1)=ma; % 倒数第二列记录分割位置(分成规则的前件、后件)
				rule(rule_count,ma+mb+2)=pab; % 倒数第一列记录置信度
            end
			cnt_b=0;
			for i=1:na
				for j=1:n
					if all(ismember(b,x{j}),2)==1 % all函数判断向量是否全为1，参数2表示按行判断
						cnt_b=cnt_b+1;%计算反过来的关联规则，即b为前项，a为后项
					end
				end
			end
			pba=cnt_ab/cnt_b;
			if pba>=min_con % 关联规则b->a的置信度大于等于最小置信度，是强关联规则
				rule_count=rule_count+1;
				rule(rule_count,1:mb)=b;
				rule(rule_count,mb+1:mb+ma)=a;
				rule(rule_count,mb+ma+1)=mb; % 倒数第二列记录分割位置(分成规则的前件、后件)
				rule(rule_count,mb+ma+2)=pba; % 倒数第一列记录置信度
			end
		end
	end
end

fprintf("当最小支持度为%.2f，最小置信度为%.2f时，生成的强关联规则以及置信度：\n",min_sup,min_con);
rule=unique(rule,'row');
[nr,mr]=size(rule);
for i=1:nr
	pos=rule(i,mr-1); % 倒数第二列断开位置，1:pos为规则前件，pos+1:mr-2为规则后件
	for j=1:pos%写前项
		if j==pos
			fprintf("%s",char(dataset(rule(i,j))));%取出序号到dataset中找到对应商品名称，以下均是
		else 
			fprintf("%s∧",char(dataset(rule(i,j))));
		end
	end
	fprintf(" => ");
	for j=pos+1:mr-2%写后项
		if j==mr-2
			fprintf("%s",char(dataset(rule(i,j))));
		else 
			fprintf("%s∧",char(dataset(rule(i,j))));
		end
	end
	fprintf("\t\t\t\t\t%f\n",rule(i,mr));
end
