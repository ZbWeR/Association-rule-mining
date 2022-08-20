clear;clc;%运行前请将dataset.xlsx文件移到对应位置

min_sup=input("请输入最小支持度([0,1]的小数，示例：0.4)\n"); % 最小支持度
min_con=input("请输入最小置信度([0,1]的小数，示例：0.9)\n"); % 最小置信度

[num,txt,raw]=xlsread('E:\Desktop\dataset.xlsx');%读取原始数据库，将原始数据库以cell形式储存在raw中
[n,m]=size(raw);%得到raw的行数n,列数m
dataset=raw(2,2:m);%获取raw中每一列对应的商品名称
data=raw(3:n,2:m);%获取raw中的购物数据
data=cell2mat(data);%将cell转为矩阵，才能使用find
[N,M]=size(data);%获取处理后行数和列数
L=[];
for i=1:N
	D{i}=find(data(i,:)=='T');% 求每行购买商品的编号
    L=union(L,D{i});%将所有数据合并得到不重复的所有元素种类
end
L=L';%行向量转置为列向量
p={};%创建空元胞数组,即倒排数据集
k=0;
for i=1:length(L)%遍历每一种元素
    k=k+1;%代替i索引L中元素，为后面不满足支持度删除做铺垫
    t=1;
    p{1}(k,1)=L(k,1);%将矩阵中的元素目录（即倒排一项集）转存到元胞数组中
    for j=1:N%遍历数据库的每一个元胞数组(即每一个事务数据集)
        if ismember(L(k,1),D{j})%判断第i个元素是否在D中的第j个数据集中
            p{2}(k,t)=j;%将元素所在事务集编号存储在对应元素后一个单元
            t=t+1;%后一个单元中存储的序号
        end
    end
    if length(p{2}(k,:))/N<min_sup%如果长度小于支持度
        p{1}(k,:)=[];%删除该元素
        p{2}(k,:)=[];%删除该元素所对应的事务集编号
        k=k-1;%让下一个元素顶替该元素位置
    end
end
i=1;
while 1
    t=0;
    [m,n]=size(p{i,1});
    for j=1:m
        for k=1:m-j%第j个频繁项与剩余项排列组合
            [~,~,tmp]=find(intersect(p{i,2}(j,:),p{i,2}(j+k,:)));%取交集得到非0元素到tmp中
            if length(tmp)/N>=min_sup%满足最小支持度
                if length(union(p{i,1}(j,:),p{i,1}(j+k,:)))==i+1%避免在2项频繁集中出现三项频繁集
                    t=t+1;
                    if t==1
                        p{i+1,1}(t,:)=union(p{i,1}(j,:),p{i,1}(j+k,:));%对满足最小支持度的频繁集所对应的项集进行组合
                        p{i+1,2}(t,:)=tmp;
                    else
                        tep=union(p{i,1}(j,:),p{i,1}(j+k,:));
                        h=~ismember(tep,p{i+1,1},'row');
                        if ~ismember(tep,p{i+1,1},'row')
                            p{i+1,1}(t,:)=tep;
                            p{i+1,2}(t,1:length(tmp))=tmp;
                        end
                    end
                end
            end
        end
    end
    i=i+1;
    if t==0
        break;
    end
end
fprintf("\n");
j=i-1;
[nL,mL]=size(p{j,1});%处理最大频繁项集，取行和列序号
rule_count=0;
for k=1:nL %  频繁项序号（行）
	p_last=p{j,1}(k,:); % 取出频繁项（一个行向量）
	cnt_ab=0;
	for x=1:N
		if all(ismember(p_last,D{x}),2)==1% all函数判断向量是否全为1，参数2表示按行判断
			cnt_ab=cnt_ab+1;%整个频繁项的支持度（未除n）
		end
    end
	len=floor(length(p_last)/2);%根据分裂规律，偶数个除2，奇数个减一除2，故直接除2向-∞取整
	for x=1:len
		s=nchoosek(p_last,x); % 从行向量L_last中选i个数的所有组合矩阵
		[ns,ms]=size(s);%组合矩阵大小
		for y=1:ns
			a=s(y,:);%a为某个组合，即前项
			b=setdiff(p_last,a);%取出a后剩下的后项
			[na,ma]=size(a);
			[nb,mb]=size(b);
			cnt_a=0;
			for x=1:na
				for y=1:N
					if all(ismember(a,D{y}),2)==1 % all函数判断向量是否全为1，参数2表示按行判断
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
			for x=1:na
				for y=1:N
					if all(ismember(b,D{y}),2)==1 % all函数判断向量是否全为1，参数2表示按行判断
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

for x=1:nr
	pos=rule(x,mr-1); % 倒数第二列断开位置，1:pos为规则前件，pos+1:mr-2为规则后件
	for y=1:pos%写前项
		if y==pos
			fprintf("%s",char(dataset(rule(x,y))));
		else 
			fprintf("%s∧",char(dataset(rule(x,y))));
		end
	end
	fprintf(" => ");
	for y=pos+1:mr-2%写后项
		if y==mr-2
			fprintf("%s",char(dataset(rule(x,y))));
		else 
			fprintf("%s∧",char(dataset(rule(x,y))));
		end
	end
	fprintf("\t\t\t\t\t%f\n",rule(x,mr));
end

