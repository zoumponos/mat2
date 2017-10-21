% 1) select inport data
% 2) select 02_movements.csv
% 3) select delimited
% 4) press ctrl+A and import selection
% 5) close window
% 6) run script: ctrl+a from editor & ctrl+c, ctrl+v in matlab & enter
% 7) input all needed data

% uiopen('C:\Users\Zoumponos DELL\Desktop\02_Movements.csv',1)


SEATRAC_Name=input('Enter SEATRAC Name as string = ')
SEATRAC_Length=input('Enter SEATRAC length in meters = ')
MultipleData=input('Enter 1 for multiple = ')
 
%-----A-----Placing Records in the Correct Order --------------------------
if(MultipleData==1)
    [Record_x,ia,ib] = union(Record,Record1,'stable');
    [Record_A,order_A]=sort(Record_x);
    [num,n]=size(order_A);
    Record_A=Record_A(1:num-1);
    order_A=order_A(1:num-1);
    Cause_x=[Cause(ia,:)' Cause1(ib,:)']';
    Cause_A=Cause_x(order_A);
    DateM_x=[DateM(ia,:)' DateM1(ib,:)']';
    DateM_A=DateM_x(order_A);
    Duration_x=[Duration(ia,:)' Duration1(ib,:)']';
    Duration_A=Duration_x(order_A);
    Land_x=[Land(ia)' Land1(ib)']';
    Land_A=Land_x(order_A);
    MeanMovCur_x=[MeanMovCur(ia)' MeanMovCur1(ib)']';
    MeanMovCur_A=2*MeanMovCur_x(order_A);
    MovementNumber_x=[MovementNumber(ia)' MovementNumber1(ib)'];
    MovementNumber_A=MovementNumber_x(order_A);
    TimeM_x=[TimeM(ia,:)' TimeM1(ib,:)']';
    TimeM_A=TimeM_x(order_A);
else
    [Record_A,order_A]=sort(Record);
    Cause_A=Cause(order_A); DateM_A=DateM(order_A); Duration_A=Duration(order_A);
    Land_A=Land(order_A); MeanMovCur_A=2*MeanMovCur(order_A); MovementNumber_A=MovementNumber(order_A);
    TimeM_A=TimeM(order_A);
end
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

%-----B-----Basic transformations------------------------------------------
[num,n]=size(order_A);
S_A(1:num-1)=0; L_A(1:num-1)=0;
a=char(Cause_A);
b=a(:,1);
for i=2:num-1
    if and(b(i)=='L',b(i-1)=='S');
        L_A(i)=1;
    elseif and(b(i)=='S',b(i-1)=='L');
        S_A(i)=1;
    end
end
pS_A(1:num-1)=1; pL_A(1:num-1)=1;
for i=2:num-1
    if S_A(i)>0
        pS_A(i)=i;
    else
        pS_A(i)=pS_A(i-1);
    end
    if L_A(i)>0
        pL_A(i)=i;
    else
        pL_A(i)=pL_A(i-1);
    end
end
DurationString_A(1:num-1,1:14)=' ';
TimeDur_A(1:num-1)=0;
for i=1:num-1
    j=length(char(Duration_A(i))); DurationString_A(i,15-j:14)=char(Duration_A(i));
    TimeDur_A(i)=(str2num(DurationString_A(i,12:14))/1000+str2num(DurationString_A(i,9:10)) ...
        +str2num(DurationString_A(i,6:7))*60+str2num(DurationString_A(i,3:4))*3600);
    if DurationString_A(i,1)=='-'
        TimeDur_A(i)=-TimeDur_A(i);
    end
end
LL=0; SS=0;start_A=1;
for i=1:num-1
    if or(LL<1,SS<1)
        if L_A(i)==1
            LL=1;
            start_A=i;
        end
        if S_A(i)==1
            SS=1;
            start_A=i;
        end
    end
end
DateString_B(1:num-1,1:10)=' '; formatIn = 'yyyy-mm-dd';
DateNum_B(1:num-1)=0; DeltaDate_B(1:num-1)=0;
for i=1:num-1
    % tranforming date to number
    DateNum_B(i)=datenum(DateM_A(i));
end
X=max(DateNum_B); 
II(1:201)=1;
for jj=200:-1:1
    if isempty(find(DateNum_B==X-jj+1,1))==1
        II(jj)=II(jj+1);
    else
        II(jj)=find(DateNum_B==X-jj+1,1);
    end
end
I1 = II(1); I2 = II(2); I7 = II(7); I14 = II(14); I21 = II(21); I30 = II(30); I60 = II(60); I90 = II(90);



%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

%-----C-----Movement Stops Positions---------------------------------------
figure; hold on; title(['Thesi & Logos Stasis Kiniseon '  SEATRAC_Name]); xlabel('A/A kinisis'); ylabel('Apostasi Stasis apo Pirgo'); set(gca, 'YGrid', 'on');
F1=gcf; F1=get(F1,'Number');

figure; hold on; title(['Thesi & Logos Stasis Kiniseon '  SEATRAC_Name]); xlabel('Imerominia'); ylabel('Apostasi Stasis apo Pirgo'); set(gca, 'YGrid', 'on');
F2=gcf; F2=get(F2,'Number');

position_A(1:num-1)=0;
ampere=0;
Aroutes=0;
A10=0;
Routes_num=0;
A10(1:num-1)=0;
for i=start_A+1:num-1
    if b(i)=='L'
        position_A(i)=0;
    elseif b(i)=='S'
        position_A(i)=1;
    elseif TimeDur_A(i)<=0
        position_A(i)=position_A(i-1)-TimeDur_A(i)/TimeDur_A(pL_A(i));
    else
        position_A(i)=position_A(i-1)+TimeDur_A(i)/TimeDur_A(pS_A(i));
    end
    if TimeDur_A(i)<=0
        shape_A='v';
    else
        shape_A='^';
    end
    if or(b(i)=='S',b(i)=='L')
        Routes_num=Routes_num+1;
        if ampere<1
            color_A='k';
            Aroutes(Routes_num)=0;
        else
            color_A='m';
            Aroutes(Routes_num)=1;
            ampere=0;
        end
    elseif or(or(b(i)=='E',b(i)=='H'),or(b(i)=='A',b(i)=='A'))
        color_A='r';
        ampere=1;
    else
        color_A='g';
    end
    % figure(F1); plot(i,min(max(1+(SEATRAC_Length-1.5)*position_A(i),0),SEATRAC_Length),[shape_A color_A]) % seatrac length 12.5
    % figure(F2); plot(DateNum_B(i),min(max(1+(SEATRAC_Length-1.5)*position_A(i),0),SEATRAC_Length),[shape_A color_A]) % seatrac length 12.5
    IX(i)=i;
    YPosition(i)=min(max(1+(SEATRAC_Length-1.5)*position_A(i),0),SEATRAC_Length);
    DateX(i)= DateNum_B(i);
    SYMBOL(i,:)=[shape_A color_A];

    if Routes_num>10
        A10(i)=Aroutes(Routes_num);
        j=1;
        while j<10
            A10(i)=A10(i)+Aroutes(Routes_num-j);
            j=j+1;
            
        end
    end
end
figure(F1);
for i=start_A+1:num-1
    plot(IX(i),YPosition(i),SYMBOL(i,:));
end
plot([I1 I1],[0 SEATRAC_Length],'ro-');plot([I2 I2],[0 SEATRAC_Length],'bx-');
plot([I7 I7],[0 SEATRAC_Length],'gs:'); plot([I14 I14],[0 SEATRAC_Length],'ks:'); plot([I21 I21],[0 SEATRAC_Length],'ms:');
plot([I30 I30],[0 SEATRAC_Length],'rd--'); plot([I60 I60],[0 SEATRAC_Length],'bd--'); plot([I90 I90],[0 SEATRAC_Length],'gd--');

figure(F2);
for i=start_A+1:num-1
    plot(DateX(i),YPosition(i),SYMBOL(i,:));
end
dateFormat = 1; tickaxis='x';
XMIN=min(DateNum_B); XMAX=max(DateNum_B);
xticks('auto')
xticks(XMIN:7:XMAX);
xticklabels(XMIN:7:XMAX);
haxis=axis; axis([XMIN XMAX haxis(3) haxis(4)]);
datetick(tickaxis,dateFormat,'keeplimits','keepticks');xtickangle(45);
set(gca, 'XGrid', 'on');


figure; plot(A10,'bo--'); hold on; title(['Logos Staseon apo Entasi '  SEATRAC_Name]); xlabel('A/A kinisis'); ylabel('Diadromes ana 10 me stasi entsis');
plot([I1 I1],[0 10],'ro-');plot([I2 I2],[0 10],'bx-');
plot([I7 I7],[0 10],'gs:'); plot([I14 I14],[0 10],'ks:'); plot([I21 I21],[0 10],'ms:');
plot([I30 I30],[0 10],'rd--'); plot([I60 I60],[0 10],'bd--'); plot([I90 I90],[0 10],'gd--');
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

%-----D-----Route Duration & Current --------------------------------------
Ft=0; Fa=0; Rt=0; Ra=0; Ct=0; Ca=0; sT=0; sAT=0; x=0; jf=0; jr=0; jc=0; cT=0; cAT=0;
for i=2:num-1
    if x==1
        if TimeDur_A(i)>=0
            sT=TimeDur_A(i)+sT;
            sAT=TimeDur_A(i)*MeanMovCur_A(i)+sAT;
        else
            cT=sT-TimeDur_A(i);
            cAT=TimeDur_A(i)*MeanMovCur_A(i)+cAT;
            sT=0;
            sAT=0;
            x=0;
            
        end
    end
    if x==-1
        if TimeDur_A(i)<=0
            sT=-TimeDur_A(i)+sT;
            sAT=TimeDur_A(i)*MeanMovCur_A(i)+sAT;
        else
            cT=sT+TimeDur_A(i);
            cAT=TimeDur_A(i)*MeanMovCur_A(i)+cAT;
            sT=0;
            sAT=0;
            x=0;
        end
    end    
    if x==0
    	cT=sT+abs(TimeDur_A(i));
        cAT=TimeDur_A(i)*MeanMovCur_A(i)+cAT;
    end
    if b(i-1)=='L'
        if TimeDur_A(i)>=0
            sT=TimeDur_A(i);
            sAT=TimeDur_A(i)*MeanMovCur_A(i);
            x=1;
        else
            sT=0;
            sAT=0;
            x=0;
        end
    end
    if b(i-1)=='S'
        if TimeDur_A(i)<=0
            sT=-TimeDur_A(i);
            sAT=TimeDur_A(i)*MeanMovCur_A(i);
            x=-1;
        else
            sT=0;
            sAT=0;
            x=0;
        end
    end
    if and(b(i)=='S',x==1)
        jf=jf+1;
        Ft(jf)=sT; Fa(jf)=sAT/sT;
        Xf(jf)=i;
        Df(jf)=DateNum_B(i);
        sT=0;
        sAT=0;
        x=0;
        cT=0;
        cAT=0;
    elseif and(b(i)=='L',x==-1)
        jr=jr+1;
        Rt(jr)=sT; Ra(jr)=sAT/sT;
        Xr(jr)=i;
        Dr(jr)=DateNum_B(i);
        sT=0;
        sAT=0;
        x=0;
        cT=0;
        cAT=0;
    else
        jc=jc+1;
        Ct(jc)=min(cT/2,160); Ca(jc)=cAT/cT;
        Xc(jc)=i;
        cT=0;
        cAT=0;        
    end
end
figure; hold on ; title(['Diarkia Diadromon '  SEATRAC_Name]); xlabel('A/A kinisis termatismou diadromis'); ylabel('Diarkia Diadromis (sec)');
limited=(max(max(Rt),max(Ft))+10); plot(Xr,Rt,'ro'); plot(Xf,Ft,'bo'); haxis=axis; axis([haxis(1) haxis(2) 0 limited])
plot([I1 I1],[0 limited],'ro-');plot([I2 I2],[0 limited],'bx-');
plot([I7 I7],[0 limited],'gs:'); plot([I14 I14],[0 limited],'ks:'); plot([I21 I21],[0 limited],'ms:');
plot([I30 I30],[0 limited],'rd--'); plot([I60 I60],[0 limited],'bd--'); plot([I90 I90],[0 limited],'gd--');
% plot(Xc,Ct,'mo');
figure; hold on ; title(['Katanalosi Diadromon '  SEATRAC_Name]); xlabel('A/A kinisis termatismou diadromis'); ylabel('Mesi Katanalosi Kinitira (A)');
limited=(max(max(Ra),max(Fa))+1); plot(Xr,Ra,'ro'); plot(Xf,Fa,'bo');  haxis=axis; axis([haxis(1) haxis(2) 0 limited])  
plot([I1 I1],[0 limited],'ro-');plot([I2 I2],[0 limited],'bx-');
plot([I7 I7],[0 limited],'gs:'); plot([I14 I14],[0 limited],'ks:'); plot([I21 I21],[0 limited],'ms:');
plot([I30 I30],[0 limited],'rd--'); plot([I60 I60],[0 limited],'bd--'); plot([I90 I90],[0 limited],'gd--');
% plot(Xc,Ca,'mo');
%//////////////////
dateFormat = 1; tickaxis='x';
XMIN=min(Dr); XMAX=max(Dr);
figure; hold on ; title(['Diarkia Diadromon '  SEATRAC_Name]); xlabel('Imerominia'); ylabel('Diarkia Diadromis (sec)');
limited=(max(max(Rt),max(Ft))+10); plot(Dr,Rt,'ro'); plot(Df,Ft,'bo'); haxis=axis; axis([haxis(1) haxis(2) 0 limited])
xticks('auto')
xticks(XMIN:7:XMAX);
xticklabels(XMIN:7:XMAX);
haxis=axis; axis([XMIN XMAX haxis(3) haxis(4)]);
datetick(tickaxis,dateFormat,'keeplimits','keepticks');xtickangle(45);
set(gca, 'XGrid', 'on');
%///////////////////////
figure; hold on ; title(['Katanalosi Diadromon '  SEATRAC_Name]); xlabel('Imerominia'); ylabel('Mesi Katanalosi Kinitira (A)');
limited=(max(max(Ra),max(Fa))+1); plot(Dr,Ra,'ro'); plot(Df,Fa,'bo');  haxis=axis; axis([haxis(1) haxis(2) 0 limited])  
xticks('auto')
xticks(XMIN:7:XMAX);
xticklabels(XMIN:7:XMAX);
haxis=axis; axis([XMIN XMAX haxis(3) haxis(4)]);
datetick(tickaxis,dateFormat,'keeplimits','keepticks');xtickangle(45);
set(gca, 'XGrid', 'on');
