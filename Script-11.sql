-- selecting saved tests/panels in the order with their setting
SELECT 'Test' AS 'Test/Panel', t.LABNO, CONCAT(md.TEST_TYPE, ' - ', md.MNEMONIC, ' - ', md.LABEL) AS 'Test Name', 
t.CUSTOMER_ORDER_ID, t.PRIORITY 'Priority Status',
	CASE 
		when t.REFLEXABLE = '0' then 'Unchecked'
		ELSE 'Checked'
	END as 'Reflex Status'
FROM TEST_MST AS md
	INNER JOIN ORDER_TEST AS t ON t.MD_TEST_ID = md.ID AND t.STATUS =1 AND t.PANEL_ID IS NULL 
	INNER JOIN ORDERS o ON o.ID =t.ORDER_ID 
WHERE o.ACC_ID = 'ID120909'
UNION 
SELECT 'Panel', p.LABNO, CONCAT(mp.TEST_TYPE, ' - ', mp.MNEMONIC,' - ', mp.LABEL), p.CUSTOMER_ORDER_ID, 
p.PRIORITY, 
	CASE 
		when p.REFLEXABLE = '0' then 'Unchecked'
		ELSE 'Checked'
	END  
FROM PANEL_MST mp 
	INNER JOIN ORDER_PANEL p ON p.MD_PANEL_ID = mp.ID AND p.STATUS =1
	INNER JOIN ORDERS o ON o.ID = p.ORDER_ID 
WHERE o.ACC_ID ='ID120909'
