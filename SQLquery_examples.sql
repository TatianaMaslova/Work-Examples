-- NOTE: Table/column names in provided queries have been changed. All coincidences are random.

-- selecting saved tests/panels in the order with specified setting
SELECT 'Test' AS 'Test/Panel', t.LABNO, CONCAT(md.TEST_TYPE, ' - ', md.MNEMONIC, ' - ', md.LABEL) AS 'Test Name', 
t.CUSTOMER__ID, t.PRIORITY 'Priority Status',
	CASE 
		when t.REFLEXABLE = '0' then 'Unchecked'
		ELSE 'Checked'
	END as 'Reflex Status'
FROM TEST_MST AS md
	INNER JOIN ORDERED_TEST AS t ON t.TEST_MST_ID = md.ID AND t.STATUS =1 AND t.PANELID IS NULL 
	INNER JOIN ORDERS o ON o.ID =t.ORDER_ID 
WHERE o.ACC_ID = 'XXX'
UNION 
SELECT 'Panel', p.LABNO, CONCAT(mp.TEST_TYPE, ' - ', mp.MNEMONIC,' - ', mp.LABEL), p.CUSTOMER__ID, 
p.PRIORITY, 
	CASE 
		when p.REFLEXABLE = '0' then 'Unchecked'
		ELSE 'Checked'
	END  
FROM PANEL_MST mp 
	INNER JOIN ORDERED_PANEL p ON p.PANEL_MST_ID = mp.ID AND p.STATUS =1
	INNER JOIN ORDERS o ON o.ID = p.ORDER_ID 
WHERE o.ACC_ID ='XXX';


SELECT CONCAT(mt.LABEL , ' - ', t.LABNO) as "Test", t.STATE, t.CUSTOMER_ID, ' - ' as 'Related GC-Panel state' FROM TEST_MST mt 
INNER JOIN ORDERED_TEST AS t ON t.TEST_MST_ID = mt.ID and t.STATUS =1 and t.PID is null and t.LABNO is not null
inner join ORDERS o on o.ID =t.ORDER_ID 
WHERE t.STATE not in ('PEN', 'CAN', 'DRAFT', 'ERR', 'CC') and o.ACC_ID = 'XXX'
union
SELECT CONCAT(mt.LABEL , ' - ', t.LABNO), t.STATE, t.CUSTOMER_ID, p2.STATE FROM TEST_MST mt 
INNER JOIN ORDERED_TEST t ON t.TEST_MST_ID = mt.ID and t.STATUS =1 and t.PID is not null and t.LABNO is not null and mt.GC_NOTE =1
inner join ORDERED_PANEL p2 on p2.ID =t.PID 
inner join ORDERS o on o.ID =t.ORDER_ID 
WHERE t.STATE not in ('PEN', 'CAN', 'DRAFT', 'ERR', 'CC') and o.ACC_ID = 'XXX'
UNION 
SELECT CONCAT(mp.LABEL , ' - ', p.LABNO), p.STATE, p.CUSTOMER_ID, ' - '  FROM  PANEL_MST mp 
inner join ORDERED_PANEL p on p.PANEL_PID =mp.ID and p.STATUS =1
inner join ORDERS o on o.ID =p.ORDER_ID 
where p.STATE not in ('PEN', 'CAN', 'DRAFT', 'ERR', 'CC') and o.ACC_ID = 'XXX'
ORDER by "Test";


Select concat(mp.TEST_TYPE, ' - ', mp.MNEMONIC, ' - ', mp.LABEL) as 'Panel Name' ,
	 CONCAT(mt.TEST_TYPE, ' - ', mt.MNEMONIC, ' - ', mt.LABEL) as 'Panel Parts',  
	 p.LABNO 'Panel Lab#', concat (p.STATE, ' - ', mpts.LABEL) 'PANEL State', t.LABNO 'PP Lab#', concat (t.STATE, ' - ', mts.LABEL) 'PP State', 
	 CONCAT(t.GSTATE, ' - ', mgs.LABEL) 'GC State', mt.GNOTE,
	 p.CHANGEDORDER 'Panel Change Order', p.SUBMITFLAG 'Panel Submetted Flag', 
	 t.CHANGEDORDER 'PP Change Order', t.SUBMITFLAG 'PP Submetted Flag' 
FROM ORDERED_TEST t
inner join ORDERS o on o.ID =t.ORDER_ID 
inner join TEST_MST mt on mt.ID = t.MD_TEST_ID and mt.STATUS =1
inner join ORDERED_PANEL p ON p.ID = t.PANELID 
inner join PANEL_MST mp on mp.ID =p.PANELID 
inner join TEST_STAT mts on mts.MNEMONIC = t.STATE 
inner join PANEL_TEST_STAT mpts on mpts.MNEMONIC = p.STATE 
left JOIN GSTAT mgs on mgs.MNEMONIC = t.GSTATE 
Where t.status=1 and t.PANELID is not null and o.ACC_ID = 'XXX';


-- selecting all tests containing any questions with predefinded any answers
Select DISTINCT p.STATUS, p.ID, p.TEST_TYPE, p.MNEMONIC, p.LABEL, p.P_CATEGORY_ID, a.MNEMONIC, a.QUESTION, a.DATA_TYPE FROM PANEL_MST as p
INNER JOIN TEST_MDAOE as ta ON p.TEST_ID=ta.TEST_ID 
INNER join AOE_MST a on a.ID =ta.MD_AOE_ID 
left JOIN AOE_VALUES_MST v on v.AOE_ID = a.ID 
WHERE p.TEST_TYPE!='NULL' 
and p.TEST_ID in 
	(
		SELECT mt.TEST_ID FROM TEST_MDAOE mt 
		where mt.MDAOE_ID IN 
		(
			SELECT v.AOE_ID FROM AOE_VALUES_MST v WHERE v.`DEFAULT` = 1
		)
	)
and p.STATUS='1' and p.P_CATEGORY_ID is not NULL 
ORDER by p.MNEMONIC;

-- view info of selected record
select p.NPI, L.SNP_PROTOCOL, p.PROVIDER_IDENTIFIER, p.EXTERNAL_PROVIDER_ID,
       pc.BLANKET_TEST_CONSENT, pl.ATTESTATION, p.LAST_NAME, p.FIRST_NAME, p.MIDDLE_NAME, pc.ID,
       pc.MNEMONIC 'PRACTICE_MNEMONIC',
       a.NAME 'Account', pc.NAME 'Practice name', L.MNEMONIC 'Loc MNEMONIC',
       IF(IFNULL(concat(IF(L.ADDRESS_LINE_1 <> '', L.ADDRESS_LINE_1, ''),
            IF(L.ADDRESS_LINE_2 <> '', concat(IF(L.ADDRESS_LINE_1 <> '', ', ', ''), L.ADDRESS_LINE_2), ''),
            IF(L.CITY <> '', concat(IF(L.ADDRESS_LINE_1 <> '' OR L.ADDRESS_LINE_2 <> '', ', ', ''), L.CITY), ''), IFNULL(IF(L.STATE_ID <> '', concat(IF(L.ADDRESS_LINE_1 <> '' OR L.ADDRESS_LINE_2 <> '' OR L.CITY <> '', ', ', ''), (select LABEL from MD_STATE where ID = L.STATE_ID)),''),
            IF(L.STATE <> '', concat(IF(L.ADDRESS_LINE_1 <> '' OR L.ADDRESS_LINE_2 <> '' OR L.CITY <> '', ', ', ''), L.STATE), '')),
            IF(L.COUNTRY_ID <> '', concat(IF(L.ADDRESS_LINE_1 <> '' OR L.ADDRESS_LINE_2 <> '' OR L.CITY <> '' OR L.STATE_ID <> '' OR L.STATE <> '', ', ', ''), (select LABEL from MD_COUNTRY where ID = L.COUNTRY_ID)), ''),
            IF(L.ZIP_CODE <> '', concat(
            IF(L.ADDRESS_LINE_1 <> '' OR L.ADDRESS_LINE_2 <> '' OR L.CITY <> '' OR L.STATE_ID <> '' OR L.STATE <> '' OR L.COUNTRY_ID <> '', ', ', ''), L.ZIP_CODE), '')), '') = '', L.NAME,
            concat(IF(L.ADDRESS_LINE_1 <> '', L.ADDRESS_LINE_1, ''),
            IF(L.ADDRESS_LINE_2 <> '', concat(IF(L.ADDRESS_LINE_1 <> '', ', ', ''), L.ADDRESS_LINE_2), ''),
            IF(L.CITY <> '', concat(IF(L.ADDRESS_LINE_1 <> '' OR L.ADDRESS_LINE_2 <> '', ', ', ''), L.CITY), ''), IFNULL(IF(L.STATE_ID <> '', concat(IF(L.ADDRESS_LINE_1 <> '' OR L.ADDRESS_LINE_2 <> '' OR L.CITY <> '', ', ', ''), (select LABEL from MD_STATE where ID = L.STATE_ID)),''),
            IF(L.STATE <> '', concat(IF(L.ADDRESS_LINE_1 <> '' OR L.ADDRESS_LINE_2 <> '' OR L.CITY <> '', ', ', ''), L.STATE), '')),
            IF(L.COUNTRY_ID <> '', concat(IF(L.ADDRESS_LINE_1 <> '' OR L.ADDRESS_LINE_2 <> '' OR L.CITY <> '' OR L.STATE_ID <> '' OR L.STATE <> '', ', ', ''), (select LABEL from MD_COUNTRY where ID = L.COUNTRY_ID)), ''),
            IF(L.ZIP_CODE <> '', concat(
            IF(L.ADDRESS_LINE_1 <> '' OR L.ADDRESS_LINE_2 <> '' OR L.CITY <> '' OR L.STATE_ID <> '' OR L.STATE <> '' OR L.COUNTRY_ID <> '', ', ', ''), L.ZIP_CODE), '')))
       as 'Location', pp.FAX, L.ID 'Loc.ID', pl.PROVIDER_ID
FROM ALL_LOCATIONS as L
    JOIN LOC_PROVIDER as pl ON (L.ID = pl.LOCID and pl.STATUS = 1)
    JOIN ALL_PROVIDERS as p ON (p.ID = pl.PR_ID and p.STATUS = 1)
    JOIN ALL_PRACTICES as pc ON (pc.ID = L.PRACT_ID and pc.STATUS = 1)
    left JOIN ALL_PREFERENCES pp on (pl.ID=pp.PROVIDER_LOCATION_ID)
    JOIN ALL_ACCOUNTS a on a.ID =pc.ACC_ID 
where L.STATUS=1 and p.NPI ='XXX' ;


-- selecting all records containing only one location and specified settings
select *, count(NPI)
from (
         select p.NPI, p.LAST_NAME, p.FIRST_NAME,
                pc.MNEMONIC as PRACTICE_MNEMONIC, pc.BLANKET_TEST_CONSENT, pl.ATTESTATION ,
                count(pl.LOCATION_ID)
         FROM ALL_LOCATIONS as l
                  JOIN LOC_PROVIDER as pl ON (l.ID = pl.LOCATION_ID and pl.STATUS = 1)
                  JOIN ALL_PROVIDERS as p ON (p.ID = pl.PROVIDER_ID and p.STATUS = 1)
                  JOIN ALL_PRACTICES as pc ON (pc.ID = l.PRACTICE_ID and pc.STATUS = 1 AND pc.REPORTING_PREFERENCE!='singles')
         where l.STATUS = 1 and pc.BLANKET_TEST_CONSENT =1
         group by pl.PROVIDER_ID
         having COUNT(pl.PROVIDER_ID) = 1
     ) as info
group by NPI
having count(NPI) = 1;


-- selecting all panels which contain panel parts with specified naming
SELECT mp.ID, mp.TEST_TYPE 'PANEL_TEST_TYPE', mp.MNEMONIC 'PANEL_MNEMONIC', mt.TEST_TYPE 'PP_TEST_TYPE', mt.MNEMONIC 'PP_MNEMONIC', mt.LABEL, mt.id from PANEL_COMPONENTS c
inner join TEST_MST mt on mt.ID =c.TEST_ID  and mt.STATUS =1
inner join PANEL_MST mp on mp.ID =c.PANEL_ID 
WHERE mp.ID in 
	(
		SELECT mp.ID FROM PANEL_MST mp 
		WHERE mp.STATUS =1 and mp.MNEMONIC like 'XXX%'
	)
order by mp.ID;


-- example of using GROUP_CONCAT statement 
select mdp.MNEMONIC               test,
       mdp.LABEL,
       GROUP_CONCAT(mdc.MNEMONIC) comp_mnem,
       GROUP_CONCAT(mdc.LABEL)    comp_label,
       GROUP_CONCAT(' ', mpmc.STATUS)  relationship_status,
       GROUP_CONCAT(' ', mdc.STATUS)   comp_status
from PANEL_MST mdp
         join TEST_MST mdt on mdp.TEST_ID = mdt.ID
         join ECS_TEST_TYPE mett on mdt.ECS_TEST_TYPE_ID = mett.ID
         join PANEL_COMPONENTS mpmc on mdp.ID = mpmc.PANEL_ID
         join COMPONENT mdc on mpmc.COMPONENT_ID = mdc.ID
where mett.TEST_TYPE = 'XXX'
group by test;


-- selecting all tests and panels containing questions with specified data types and not containing any required questions 
SELECT distinct 'TEST', mtt.ID 'Test/Panel ID', mtt.TEST_TYPE, mtt.MNEMONIC, mtt.LABEL FROM TEST_MST mtt
INNER JOIN ALL_AOES mt ON mt.TESTID = mtt.ID and mtt.STATUS=1
INNER JOIN ALL_AOES mt2 ON (mt2.TESTID = mt.TESTID AND mt2.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='TEXT'))
INNER JOIN ALL_AOES mt3 ON (mt3.TESTID = mt.TESTID AND mt3.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='MULTIPLE' and a.DISPLAY ='RADIO'))
INNER JOIN ALL_AOES mt4 ON (mt4.TESTID = mt.TESTID AND mt4.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='MULTIPLE' and a.DISPLAY ='SELECT'))
INNER JOIN ALL_AOES mt5 ON (mt5.TESTID = mt.TESTID AND mt5.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='DATE'))
INNER JOIN ALL_AOES mt6 ON (mt6.TESTID = mt.TESTID AND mt6.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='MULTIPLE-CHK'))
INNER JOIN ALL_AOES mt7 ON (mt7.TESTID = mt.TESTID AND mt7.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='NUMBER'))
INNER JOIN ALL_AOES mt8 ON (mt8.TESTID = mt.TESTID AND mt8.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='TIME'))
INNER JOIN ALL_AOES mt9 ON (mt9.TESTID = mt.TESTID AND mt9.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='TEXTAREA'))
WHERE mt.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='YN')
and mtt.ID not in (SELECT mt.TESTID from ALL_AOES mt WHERE mt.MANDATORY =1)
UNION 
SELECT DISTINCT 'PANEL', mp.ID, mp.TEST_TYPE, mp.MNEMONIC, mp.LABEL FROM PANEL_MST mp 
join ALL_AOES mt on mt.TESTID =mp.TESTID and mp.STATUS =1
INNER JOIN ALL_AOES mt2 ON (mt2.TESTID = mt.TESTID AND mt2.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='TEXT'))
INNER JOIN ALL_AOES mt3 ON (mt3.TESTID = mt.TESTID AND mt3.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='MULTIPLE' and a.DISPLAY ='RADIO'))
INNER JOIN ALL_AOES mt4 ON (mt4.TESTID = mt.TESTID AND mt4.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='MULTIPLE' and a.DISPLAY ='SELECT'))
INNER JOIN ALL_AOES mt5 ON (mt5.TESTID = mt.TESTID AND mt5.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='DATE'))
INNER JOIN ALL_AOES mt6 ON (mt6.TESTID = mt.TESTID AND mt6.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='MULTIPLE-CHK'))
INNER JOIN ALL_AOES mt7 ON (mt7.TESTID = mt.TESTID AND mt7.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='NUMBER'))
INNER JOIN ALL_AOES mt8 ON (mt8.TESTID = mt.TESTID AND mt8.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='TIME'))
INNER JOIN ALL_AOES mt9 ON (mt9.TESTID = mt.TESTID AND mt9.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='TEXTAREA'))
where mt.AOEID IN (SELECT a.ID FROM AOE_MST a WHERE a.DATA_TYPE='YN')
and mp.TESTID not in (SELECT mt.TESTID from ALL_AOES mt WHERE mt.MANDATORY =1);

-- selecting all tests and panels with YN-question that has several default answers and status=1
SELECT DISTINCT mt.TESTID as 'TEST/PANEL ID', 'TEST' as 'TESTS/PANELS with YN-question that has several default answers with status=1', 
a.DATA_TYPE, a.ID  'AID', a.QUESTION, mt2.TEST_TYPE, mt2.MNEMONIC FROM ALL_AOES as mt
inner join TEST_MST mt2 on mt2.ID =mt.TESTID and mt2.STATUS =1
inner join AOE_MST a on mt.AOE_MST_ID = a.ID and a.STATUS =1
where a.DATA_TYPE='YN' and mt.AOE_MST_ID in (SELECT v.AID FROM AOE_MST_VALUES v WHERE v.`DEFAULT`=1 and v.STATUS =1 
GROUP by v.AID HAVING COUNT(v.AID)>1)
UNION 
SELECT mp.ID, 'PANEL', a.DATA_TYPE, a.ID, a.QUESTION, mp.TEST_TYPE, mp.MNEMONIC FROM ALL_AOES as mt
inner join PANEL_MST mp on mp.TESTID =mt.TESTID and mp.STATUS =1
inner join AOE_MST a on mt.AOE_MST_ID = a.ID and a.STATUS =1
where a.DATA_TYPE='YN' and mt.AOE_MST_ID in (SELECT v.AID FROM AOE_MST_VALUES v WHERE v.`DEFAULT`=1 and v.STATUS =1 
GROUP by v.AID HAVING COUNT(v.AID)>1);


-- all tests and panels that have more than 1 question
SELECT 'TEST', t.ID, t.TEST_TYPE as "TEST_TYPE", t.MNEMONIC, t.LABEL FROM  TEST_MST t
inner join ALL_AOES mt on t.ID = mt.TEST_MST_ID 
where t.ID not in (SELECT p.TEST_MST_ID from PANEL_MST p)
GROUP by t.ID
HAVING count(mt.TEST_MST_ID) > 1
union
SELECT 'PANEL', p.TEST_MST_ID, p.TEST_TYPE, p.MNEMONIC, p.LABEL FROM  PANEL_MST p 
inner join ALL_AOES mt on p.TEST_MST_ID = mt.TEST_MST_ID 
GROUP by p.TEST_MST_ID 
HAVING count(mt.TEST_MST_ID) > 1;
order by "TEST_TYPE";