#7
#Write a query to display carton id, (len*width*height) as carton_vol and identify the
##optimum carton (carton with the least volume whose volume is greater than the total
##volume of all items (len * width * height * product_quantity)) for a given order whose order
##id is 10006, Assume all items of an order are packed into one single carton (box). (1 ROW)
##[NOTE: CARTON TABLE,PRODUCT TABLE]

use orders;

SELECT C.CARTON_ID, (C.LEN*C.WIDTH*C.HEIGHT) as VOL
FROM ORDERS.CARTON C
WHERE (C.LEN*C.WIDTH*C.HEIGHT) >= (
SELECT
SUM(P.LEN*P.WIDTH*P.HEIGHT*PRODUCT_QUANTITY) AS VOL
FROM ORDERS.ORDER_HEADER OH
INNER JOIN ORDERS.ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID
INNER JOIN ORDERS.PRODUCT P ON OI.PRODUCT_ID =
P.PRODUCT_ID
WHERE OH.ORDER_ID =10006 ## Filtered the only address
)
ORDER BY (C.LEN*C.WIDTH*C.HEIGHT) ASC

####################################################################

#8
#Write a query to display details (customer id,customer fullname,order id,product
#quantity) of customers who bought more than ten (i.e. total order qty) products per shipped
#order.

SELECT C.CUSTOMER_ID, C.CUSTOMER_FULLNAME, OUT_QRY.PRODUCT_QUANTITY, H.ORDER_ID
FROM
(
SELECT ORDER_ID, PRODUCT_QUANTITY FROM ORDERS.ORDER_ITEMS
GROUP BY ORDER_ID
HAVING SUM(PRODUCT_QUANTITY) > 10
) OUT_QRY
INNER JOIN ORDERS.ORDER_HEADER H ON OUT_QRY.ORDER_ID = H.ORDER_ID AND
H.ORDER_STATUS = 'SHIPPED'
INNER JOIN
(
SELECT DISTINCT CUSTOMER_ID,
CONCAT(CUSTOMER_FNAME,' ',CUSTOMER_LNAME) AS CUSTOMER_FULLNAME FROM
ORDERS.ONLINE_CUSTOMER
) C ON H.CUSTOMER_ID = C.CUSTOMER_ID
ORDER BY C.CUSTOMER_ID

########################################################################

#9

#Write a query to display the order_id, customer id and cutomer full name of customers
#along with (product_quantity) as total quantity of products shipped for order ids > 10060. (6
#ROWS)


SELECT OI.ORDER_ID, OC.CUSTOMER_ID, CONCAT(OC.CUSTOMER_FNAME,' ',OC.CUSTOMER_LNAME) AS
CUSTOMER_NAME, OI.TOTAL_QUANTITY
FROM ORDERS.ORDER_HEADER OH
INNER JOIN
(
SELECT ORDER_ID,
SUM(PRODUCT_QUANTITY) AS TOTAL_QUANTITY FROM ORDERS.ORDER_ITEMS
GROUP BY ORDER_ID
HAVING
ORDER_ID > 10060
) OI 
ON
OH.ORDER_ID = OI.ORDER_ID AND OH.ORDER_STATUS = 'SHIPPED' 
INNER JOIN ORDERS.ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID

################################################################
#10.

#Write a query to display product class description ,total quantity
#(sum(product_quantity),Total value (product_quantity * product price) and show which class
#of products have been shipped highest(Quantity) to countries outside India other than USA?
#Also show the total value of those items.


SELECT OUT_QRY.PRODUCT_CLASS_DESC, SUM(OUT_QRY.PRODUCT_QUANTITY) PRODUCT_QUANTITY, SUM(OUT_QRY.TOTAL_VALUE) TOTAL_VALUE, OUT_QRY.PRODUCT_CLASS_CODE
	    FROM
			(
				SELECT PC.PRODUCT_CLASS_DESC, OI.PRODUCT_QUANTITY,(OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE) TOTAL_VALUE, PC.PRODUCT_CLASS_CODE
					FROM ORDERS.ORDER_ITEMS OI
						INNER JOIN ORDERS.ORDER_HEADER OH ON OH.ORDER_ID = OI.ORDER_ID AND OH.ORDER_STATUS = 'SHIPPED' 
							INNER JOIN ORDERS.ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
								INNER JOIN ORDERS.ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID AND A.COUNTRY NOT IN ('India','USA')
									LEFT JOIN ORDERS.PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
											LEFT JOIN ORDERS.PRODUCT_CLASS PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
			) OUT_QRY
GROUP BY OUT_QRY.PRODUCT_CLASS_CODE, OUT_QRY.PRODUCT_CLASS_DESC
ORDER BY SUM(OUT_QRY.PRODUCT_QUANTITY) DESC
LIMIT 1