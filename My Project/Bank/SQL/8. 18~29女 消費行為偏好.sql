SELECT
	CCT.MerchantCategory,
	count(*) as count
FROM
	CreditCardTransaction CCT
LEFT JOIN
	Customers C
USING
	(CustomerID)
WHERE
	C.Age BETWEEN 18 AND 29
AND
	C.Gender = 'Female'
GROUP by
	1
ORDER by
	2 DESC;