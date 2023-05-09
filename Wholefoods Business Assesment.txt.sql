USE fmban_sql_analysis;

/* Main question: Do healthier foods cost less? */

/* Exploratory phase */

SELECT category, COUNT(ID)
FROM fmban_data
GROUP BY (category)
ORDER BY COUNT(ID) DESC
;-- There are 11 Categories 

SELECT subcategory, COUNT(ID)
FROM fmban_data
GROUP BY (subcategory)
ORDER BY COUNT(ID) DESC
;/* 54 subcategories, null 29 products
	Ice cream & Frozen dessert 2 times, 12 and 11 products*/
    
SELECT*
FROM fmban_data
WHERE subcategory IN ('Ice cream & Frozen dessert', 'Ice Cream & frozen desserts')
;-- no duplicated records on Ice cram, 2 categories Desserts and Frozen Foods

SELECT*
FROM fmban_data
WHERE subcategory = 'NULL'
;-- 'NULL' is not NULL its a string

SELECT COUNT(ID)
FROM fmban_data
;-- There are a total of 282 products in total, 11 categories and 54 subcategories

SELECT category, subcategory, product, vegan, glutenfree, ketofriendly, vegetarian, 
		organic, dairyfree, sugarconscious, paleofriendly, wholefoodsdiet, lowsodium, 
        kosher, lowfat, engine2, price, caloriesperserving, servingsize, 
        servingsizeunits, `local`
FROM fmban_data
WHERE category IN ('Wine', 'produce')
;-- wine has different prices in units rathen than hundreds,

SELECT subcategory, AVG(caloriesperserving) 
FROM fmban_data
WHERE category IN ('wine', 'produce')
GROUP BY subcategory
; -- subcategory table 
/* Considering if wine is healthy and counting calories on average
	vs produce:
		Fresh Vegetables	45.41
		Fresh Fruits		58.5
		Fresh Herbs			5
		Red Wine			184.1
		White Wine			237.2
		Blend				125
		Chardonnay			80
*/

Select totalsizeunits, COUNT(ID)
FROM fmban_data
GROUP BY totalsizeunits
; -- size units available 

SELECT* 
FROM fmban_data
WHERE category = 'meat'
AND ID IN (189,57)
;-- there are several repited entries, where the only thinkg that changes is grams instead of g

SELECT COUNT(ID) AS lowfat1, (SELECT COUNT(ID) 
								FROM fmban_data
								WHERE lowfat=0) AS lowfat0
FROM fmban_data
WHERE lowfat=1
;-- 207 lowfat0 and lowfat1 

/*
	To unifie the price the calculation will be price per calories unifing on g as grams and for liquids  
    it is consider a equiality of 1 ml = 1 g
*/
SELECT totalsizeunits, COUNT(ID)
FROM fmban_data
GROUP BY totalsizeunits
;-- all unit of total size 

-- Main formula for price 
SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie
FROM (SELECT*, (CASE 
				WHEN totalsizeunits = 'oz'	  THEN (totalsize*28.35)
				WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
				WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 'G' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 10 	  THEN 10
				WHEN totalsizeunits = 24 	  THEN 24
				WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
				WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
				WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
				WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
				WHEN totalsize =  0 		  THEN (totalsecondarysize*1)
				WHEN totalsecondarysize = 0   THEN (servingsize*1) 
				END) AS g_totalsize
				FROM fmban_data) AS price_table
;-- this is the formula for the price unified

SELECT*, (CASE 
			WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
            WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
			WHEN totalsizeunits = 'g'     THEN (totalsize*1)
            WHEN totalsizeunits = 'G'     THEN (totalsize*1)
            WHEN totalsizeunits = 10      THEN 10
            WHEN totalsizeunits = 24      THEN 24
            WHEN totalsizeunits = 'lt'    THEN (totalsize*1000)
            WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
            WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
            WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
			WHEN totalsize =  0 		  THEN (totalsecondarysize*1)
			WHEN totalsecondarysize = 0   THEN (servingsize*1) 
			END) AS g_totalsize
FROM fmban_data
; -- test of filtering and converting units 

/* In meats pork is tagged as unhealhy in addition with any meet 
	that contains extra fat, its processed and frozen. throughout 
	the data base when a prduct is not vegan then is part of the 
	paleo diet for my definition of healthy */
-- MEAT healthy table
SELECT ID, category, subcategory, product, price,
	(CASE 
    WHEN category = 'meat' AND subcategory LIKE ('%pork%') 		THEN "unhealthy"
    WHEN category = 'meat' AND product     LIKE ('%ham%') 	  	THEN "unhealthy"
    WHEN category = 'meat' AND product 	   LIKE ('%Frozen%') 	THEN "unhealthy"
	WHEN category = 'meat' AND product 	   LIKE ('%Processed%') THEN "unhealthy"
    WHEN category = 'meat' AND product 	   LIKE ('%fat%') 		THEN "unhealthy"
	WHEN category = 'meat' AND vegan=1 							THEN "healthy"
    WHEN category = 'meat' AND paleofriendly=1 					THEN "healthy"
    ELSE "unhealthy"
    END) AS `definition`
FROM fmban_data
ORDER BY ID ASC
; -- this aplies for meats
    
-- count meat products
SELECT COUNT(ID)
FROM (SELECT ID, category, subcategory, product, price,
	(CASE 
    WHEN category = 'meat' AND subcategory LIKE ('%pork%') 		THEN "unhealthy"
    WHEN category = 'meat' AND product 	   LIKE ('%ham%') 		THEN "unhealthy"
    WHEN category = 'meat' AND product 	   LIKE ('%Frozen%') 	THEN "unhealthy"
	WHEN category = 'meat' AND product     LIKE ('%Processed%') THEN "unhealthy"
    WHEN category = 'meat' AND product 	   LIKE ('%fat%') 		THEN "unhealthy"
	WHEN category = 'meat' AND vegan=1 							THEN "healthy"
    WHEN category = 'meat' AND paleofriendly=1 					THEN "healthy"
    ELSE "unhealthy"
    END) AS `definition`
FROM fmban_data
WHERE category = 'meat') AS meeat_table
WHERE `definition` = 'healthy'
; -- count of healthy meats its 25 & unhealthy 17 

/* According to the definition pulled out from the dietary guidlines for 
	america from the FDA in combination with the definition from the
    Amercian Council on Science and Health, I determined that healthy food
    in this data base will inculde 'glutenfree', 'lowfat', 'sugarconscious'
    'lowsodium' and 'organic'. */

/* Main query for healthy definition, organic food in general is consider 
	healthier because it does not contain chemicals or pestisides among 
	others */

SELECT ID, category, subcategory, product, price, organic, glutenfree, lowfat, sugarconscious, lowsodium, wholefoodsdiet,
	(CASE 
		WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
			AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
		WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
			AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
		WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
			AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
		ELSE "unhealthy"
		END) AS `definition`
FROM fmban_data
WHERE category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods')
;-- this is aplies for ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods')

/* categories tables START ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') */
SELECT category, COUNT(ID)
FROM fmban_data
GROUP BY category
ORDER BY category ASC
;-- category table (total)

SELECT category, COUNT(ID) AS "healthy_count"
FROM (SELECT ID, category,
		(CASE 
		WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
			AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
		WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
			AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
		WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
			AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
		ELSE "unhealthy"
		END) AS `definition`
	FROM fmban_data) AS produce_Dairy_and_Eggs_prepared_foods_table
WHERE category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods')
AND `definition` = "healthy"
GROUP BY category
ORDER BY category ASC
;-- category table (healthy)

SELECT category, COUNT(ID) AS "unhealthy_count"
FROM (SELECT ID, category,
		(CASE 
		WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
			AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
		WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
			AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
		WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
			AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
		ELSE "unhealthy"
		END) AS `definition`
	FROM fmban_data) AS produce_Dairy_and_Eggs_prepared_foods_table
WHERE category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods')
AND `definition` = "unhealthy"
GROUP BY category
ORDER BY category ASC
;-- category table (unhealthy)
/* categories tables END  ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') */

/* Category table supplements */
SELECT ID, category, subcategory, product, price, organic, glutenfree, lowfat, sugarconscious, lowsodium, wholefoodsdiet,
	(CASE 
		WHEN category = 'supplements' AND organic=1 OR glutenfree=1 OR lowsodium=1 THEN "healthy"
        WHEN category = 'supplements' AND product LIKE '%detox%' THEN "unhealthy"
		ELSE "unhealthy"
		END) AS `definition`
FROM fmban_data
WHERE category = 'supplements'
;

-- count for products 'supplements'
SELECT category, COUNT(ID) AS "healthy_count", (SELECT COUNT(ID) AS "unhealthy_count"
												FROM (SELECT ID, (CASE 
													WHEN category = 'supplements' AND organic=1 OR glutenfree=1 OR lowsodium=1 THEN "healthy"
													WHEN category = 'supplements' AND product LIKE '%detox%' THEN "unhealthy"
													ELSE "unhealthy"
													END) AS `definition`
												FROM fmban_data
												WHERE category = 'supplements') AS supplements_table
												WHERE `definition` = "unhealthy") AS "unhealthy_count"
FROM (SELECT ID, category,
	(CASE 
		WHEN category = 'supplements' AND organic=1 OR glutenfree=1 OR lowsodium=1 THEN "healthy"
        WHEN category = 'supplements' AND product LIKE '%detox%' THEN "unhealthy"
		ELSE "unhealthy"
		END) AS `definition`
FROM fmban_data
WHERE category = 'supplements') AS supplements_table
WHERE `definition` = "healthy"
GROUP BY category
;-- count 14 healthy supplements & 13 unealthy supplements

/* categories tables START ('Beer', 'Beverages', 'Wine')*/
SELECT ID, category, subcategory, product, price, organic, glutenfree, lowfat, sugarconscious, lowsodium, wholefoodsdiet,
	(CASE 
    WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') THEN "healthy"
    WHEN category IN ('Beer', 'Beverages', 'Wine') AND product LIKE ('%Cider%') THEN "healthy"
    WHEN category IN ('Beer', 'Beverages', 'Wine') AND product LIKE ('%Sauvignon%') THEN "healthy"
	WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 THEN "healthy"
    ELSE "unhealthy"
    END) AS `definition`
FROM fmban_data
WHERE category IN ('Beer', 'Beverages', 'Wine')
ORDER BY category ASC
;

-- Count
SELECT category, COUNT(ID)
FROM (SELECT ID, category, subcategory, product, price, organic, glutenfree, lowfat, sugarconscious, lowsodium, wholefoodsdiet,
			(CASE 
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product LIKE ('%Cider%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product LIKE ('%Sauvignon%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 THEN "healthy"
			ELSE "unhealthy"
			END) AS `definition`
		FROM fmban_data
		WHERE category IN ('Beer', 'Beverages', 'Wine')) AS beer_beverages_wine_table
WHERE `definition` = "healthy"
GROUP BY category
;-- count(END)

/* table for NULL */

SELECT ID, category, subcategory, product, price, vegan, organic, glutenfree, lowfat, sugarconscious, lowsodium, wholefoodsdiet,
	(CASE 
	WHEN category = 'NULL' AND product LIKE ('%organic%') THEN "healthy"
	WHEN category = 'NULL' AND vegan=1 THEN "healthy"
	ELSE "unhealthy"
	END) AS `definition`
FROM fmban_data
WHERE category = 'NULL'
;

--  count NULL table 
SELECT category, COUNT(ID) AS healthy_count, (SELECT COUNT(ID)
											FROM (SELECT ID,
													(CASE 
													WHEN category = 'NULL' AND product LIKE ('%organic%') THEN "healthy"
													WHEN category = 'NULL' AND vegan=1 THEN "healthy"
													ELSE "unhealthy"
													END) AS `definition`
												FROM fmban_data
												WHERE category = 'NULL') AS null_table
											WHERE `definition` = "unhealthy") AS unhealthy_count
FROM (SELECT ID, category,
		(CASE 
		WHEN category = 'NULL' AND product LIKE ('%organic%') THEN "healthy"
		WHEN category = 'NULL' AND vegan=1 THEN "healthy"
		ELSE "unhealthy"
		END) AS `definition`
	FROM fmban_data
	WHERE category = 'NULL') AS null_table
WHERE `definition` = "healthy"
GROUP BY category
;-- count 21 healthy & 8 unhealthy


-- testing of complete formula with correct numbers per category
SELECT category, COUNT(`definition`) AS healthy_count
FROM(SELECT *, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
			(CASE 
			WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
			WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
			WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
			WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
			WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
			WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
            WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
            WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
            WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory 	   LIKE ('%Tea%') 		THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     	   LIKE ('%Cider%') 	THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	  	   LIKE ('%Sauvignon%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 					  		THEN "healthy" 
            WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
				AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			ELSE "unhealthy"
				END) AS `definition`
	FROM (SELECT*, (CASE 
				WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
				WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
				WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 'G'     THEN (totalsize*1)
				WHEN totalsizeunits = 10 	  THEN 10
				WHEN totalsizeunits = 24 	  THEN 24
				WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
				WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
				WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
				WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
				WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
				WHEN totalsecondarysize = 0   THEN (servingsize*1) 
					END) AS g_totalsize
				FROM fmban_data) AS price_table) AS tot_table
WHERE `definition` = "healthy"
GROUP BY category
ORDER BY category ASC
;
/* 
	Everything ok table with total count:
								(H)-(U)
		Beer					 3 -  7
		Beverages				15 -  7
		Bread Rolls & Bakery	11 - 10
		Dairy and Eggs			16 - 15
		Desserts				 4 - 20
		Frozen Foods			 6 - 17
		Meat					25 - 17
		NULL					21 -  8
		Prepared Foods			 2 - 12
		Produce					22 -  0
		supplements				13 - 14
		Wine					 9 -  8 
*/

/* MAIN CODE FOR ANALYSIS */

SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
		(CASE 
			WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
			WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
			WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
			WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
			WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
			WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
            WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
            WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
            WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
            WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
				AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			ELSE "unhealthy"
				END) AS `definition`
FROM (SELECT*, (CASE 
				WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
				WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
				WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 'G'     THEN (totalsize*1)
				WHEN totalsizeunits = 10 	  THEN 10
				WHEN totalsizeunits = 24 	  THEN 24
				WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
				WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
				WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
				WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
				WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
				WHEN totalsecondarysize = 0   THEN (servingsize*1) 
					END) AS g_totalsize
				FROM fmban_data) AS price_table
;-- THIS IS THE MAIN AND COMPLETE FORMULA :)

-- AVG price total, hhealthy, unhealthy 
SELECT ROUND(AVG(price_per_calorie),2) AS AVG_total_price_per_calorie, 
		(SELECT ROUND(AVG(price_per_calorie),2) AS AVG_helthy_price_per_calorie
        FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
				(CASE 
					WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
					WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
					WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
					WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
					WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
					WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
					WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
					WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
					WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
					WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
						AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
					WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
						AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
					WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
						AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
					ELSE "unhealthy"
						END) AS `definition`
			FROM (SELECT*, (CASE 
						WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
						WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
						WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
						WHEN totalsizeunits = 'G'     THEN (totalsize*1)
						WHEN totalsizeunits = 10 	  THEN 10
						WHEN totalsizeunits = 24 	  THEN 24
						WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
						WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
						WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
						WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
						WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
						WHEN totalsecondarysize = 0   THEN (servingsize*1) 
							END) AS g_totalsize
						FROM fmban_data) AS price_table) AS analysis_table
                        WHERE `definition` = "healthy") AS AVG_helthy_price_per_calorie, 
							(SELECT ROUND(AVG(price_per_calorie),2) AS AVG_unhealthy_price_per_calorie
								FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
										(CASE 
											WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
											WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
											WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
											WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
											WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
											WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
											WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
											WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
											WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
											WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
												AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
											WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
												AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
											WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
												AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
											ELSE "unhealthy"
												END) AS `definition`
									FROM (SELECT*, (CASE 
												WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
												WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
												WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
												WHEN totalsizeunits = 'G'     THEN (totalsize*1)
												WHEN totalsizeunits = 10 	  THEN 10
												WHEN totalsizeunits = 24 	  THEN 24
												WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
												WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
												WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
												WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
												WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
												WHEN totalsecondarysize = 0   THEN (servingsize*1) 
													END) AS g_totalsize
												FROM fmban_data) AS price_table) AS analysis_table
												WHERE `definition` = "unhealthy") AS AVG_unhelthy_price_per_calorie
FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
		(CASE 
			WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
			WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
			WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
			WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
			WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
			WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
            WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
            WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
            WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
            WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
				AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			ELSE "unhealthy"
				END) AS `definition`
	FROM (SELECT*, (CASE 
				WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
				WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
				WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 'G'     THEN (totalsize*1)
				WHEN totalsizeunits = 10 	  THEN 10
				WHEN totalsizeunits = 24 	  THEN 24
				WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
				WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
				WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
				WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
				WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
				WHEN totalsecondarysize = 0   THEN (servingsize*1) 
					END) AS g_totalsize
				FROM fmban_data) AS price_table) AS analysis_table
;-- AVG prices 3.74, 3.59, 3.92

-- AVG price per category 
SELECT category, ROUND(AVG(price_per_calorie),2) AS AVG_total_price_per_calorie, 
		(SELECT ROUND(AVG(price_per_calorie),2) AS AVG_helthy_price_per_calorie
        FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
				(CASE 
					WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
					WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
					WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
					WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
					WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
					WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
					WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
					WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
					WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
					WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
						AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
					WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
						AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
					WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
						AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
					ELSE "unhealthy"
						END) AS `definition`
			FROM (SELECT*, (CASE 
						WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
						WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
						WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
						WHEN totalsizeunits = 'G'     THEN (totalsize*1)
						WHEN totalsizeunits = 10 	  THEN 10
						WHEN totalsizeunits = 24 	  THEN 24
						WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
						WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
						WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
						WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
						WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
						WHEN totalsecondarysize = 0   THEN (servingsize*1) 
							END) AS g_totalsize
						FROM fmban_data) AS price_table) AS analysis_table
                        WHERE `definition` = "healthy"
                        AND category = 'Wine') AS AVG_helthy_price_per_calorie, 
							(SELECT ROUND(AVG(price_per_calorie),2) AS AVG_unhealthy_price_per_calorie
								FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
										(CASE 
											WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
											WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
											WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
											WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
											WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
											WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
											WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
											WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
											WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
											WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
												AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
											WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
												AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
											WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
												AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
											ELSE "unhealthy"
												END) AS `definition`
									FROM (SELECT*, (CASE 
												WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
												WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
												WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
												WHEN totalsizeunits = 'G'     THEN (totalsize*1)
												WHEN totalsizeunits = 10 	  THEN 10
												WHEN totalsizeunits = 24 	  THEN 24
												WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
												WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
												WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
												WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
												WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
												WHEN totalsecondarysize = 0   THEN (servingsize*1) 
													END) AS g_totalsize
												FROM fmban_data) AS price_table) AS analysis_table
												WHERE `definition` = "unhealthy"
                                                AND category = 'Wine') AS AVG_unhelthy_price_per_calorie
FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
		(CASE 
			WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
			WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
			WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
			WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
			WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
			WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
            WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
            WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
            WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
            WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
				AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			ELSE "unhealthy"
				END) AS `definition`
	FROM (SELECT*, (CASE 
				WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
				WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
				WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 'G'     THEN (totalsize*1)
				WHEN totalsizeunits = 10 	  THEN 10
				WHEN totalsizeunits = 24 	  THEN 24
				WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
				WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
				WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
				WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
				WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
				WHEN totalsecondarysize = 0   THEN (servingsize*1) 
					END) AS g_totalsize
				FROM fmban_data) AS price_table) AS analysis_table
WHERE category = 'Wine'
;
/* 	
    AVG prices per category:
						   t.avg.p h.avg.p u.avg.p
	Beer,					 0.2,	0.22,	 0.2
    Beverages,				1.27,	0.32,	2.68
    Bread Rolls & Bakery,	0.82,	0.99,	0.63
    Dairy and Eggs,			1.32,	1.04,	1.71
    Desserts,				3.71,	0.56,	4.13
    Frozen Foods,			1.26,	1.73,	0.92
	Meat,					2.03,	1.98,	2.09
    NULL,					0.01,	0.01,	0.01
    Prepared Foods,			1.56,	 2.5,	1.41
    Produce,				13.2,	13.2,	
    supplements,			15.39,	3.46,	30.74
    Wine,					3.28,	3.39,	3.15
*/

-- Count per category 
SELECT category, ROUND(COUNT(ID),2) AS COUNT_total_price_per_calorie, 
		(SELECT ROUND(COUNT(ID),2) AS COUNT_helthy_price_per_calorie
        FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
				(CASE 
					WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
					WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
					WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
					WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
					WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
					WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
					WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
					WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
					WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
					WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
					WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
					WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
						AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
					WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
						AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
					WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
						AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
					ELSE "unhealthy"
						END) AS `definition`
			FROM (SELECT*, (CASE 
						WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
						WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
						WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
						WHEN totalsizeunits = 'G'     THEN (totalsize*1)
						WHEN totalsizeunits = 10 	  THEN 10
						WHEN totalsizeunits = 24 	  THEN 24
						WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
						WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
						WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
						WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
						WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
						WHEN totalsecondarysize = 0   THEN (servingsize*1) 
							END) AS g_totalsize
						FROM fmban_data) AS price_table) AS analysis_table
                        WHERE `definition` = "healthy"
                        AND category = 'supplements') AS COUNT_helthy_price_per_calorie, 
							(SELECT ROUND(COUNT(ID),2) AS COUNT_unhealthy_price_per_calorie
								FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
										(CASE 
											WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
											WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
											WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
											WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
											WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
											WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
											WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
											WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
											WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
											WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
											WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
											WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
												AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
											WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
												AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
											WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
												AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
											ELSE "unhealthy"
												END) AS `definition`
									FROM (SELECT*, (CASE 
												WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
												WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
												WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
												WHEN totalsizeunits = 'G'     THEN (totalsize*1)
												WHEN totalsizeunits = 10 	  THEN 10
												WHEN totalsizeunits = 24 	  THEN 24
												WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
												WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
												WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
												WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
												WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
												WHEN totalsecondarysize = 0   THEN (servingsize*1) 
													END) AS g_totalsize
												FROM fmban_data) AS price_table) AS analysis_table
												WHERE `definition` = "unhealthy"
                                                AND category = 'supplements') AS COUNT_unhelthy_price_per_calorie
FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
		(CASE 
			WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
			WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
			WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
			WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
			WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
			WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
            WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
            WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
            WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
            WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
				AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			ELSE "unhealthy"
				END) AS `definition`
	FROM (SELECT*, (CASE 
				WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
				WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
				WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 'G'     THEN (totalsize*1)
				WHEN totalsizeunits = 10 	  THEN 10
				WHEN totalsizeunits = 24 	  THEN 24
				WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
				WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
				WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
				WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
				WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
				WHEN totalsecondarysize = 0   THEN (servingsize*1) 
					END) AS g_totalsize
				FROM fmban_data) AS price_table) AS analysis_table
WHERE category = 'supplements'
;
/* 		table of count per category 
							  T  H   U
		Beer				 10	 2	 8
		Beverages			 22	19	 3
		Bread Rolls & Bakery 21	11	10
		Dairy and Eggs		 31	16	15
		Desserts		     24	 4	20
		Frozen Foods	     23	 6	17
		Meat				 42	25	17
		NULL				 29	17	12
		Prepared Foods	 	 14	 2	12
		Produce				 22	22	
		supplements			 27	13	14
		Wine				 17	 9	 8
*/

/* Hypothesis Testing */

/* 
Null Hypothesis = H0 AVG price of healthy food < AVG price of all food
Alternative hypothesis = Ha AVG price of healthy food > AVG price of all food 
*/

SELECT ROUND(AVG(price_per_calorie),2) AS P_mean 
FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
		(CASE 
			WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
			WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
			WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
			WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
			WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
			WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
            WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
            WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
            WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
            WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
				AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			ELSE "unhealthy"
				END) AS `definition`
FROM (SELECT*, (CASE 
				WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
				WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
				WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 'G'     THEN (totalsize*1)
				WHEN totalsizeunits = 10 	  THEN 10
				WHEN totalsizeunits = 24 	  THEN 24
				WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
				WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
				WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
				WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
				WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
				WHEN totalsecondarysize = 0   THEN (servingsize*1) 
					END) AS g_totalsize
				FROM fmban_data) AS price_table) AS analysis_table
;-- p_mean = 3.74

SELECT COUNT(ID) AS healthy_food
FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
		(CASE 
			WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
			WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
			WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
			WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
			WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
			WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
            WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
            WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
            WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
            WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
				AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			ELSE "unhealthy"
				END) AS `definition`
		FROM (SELECT*, (CASE 
				WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
				WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
				WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 'G'     THEN (totalsize*1)
				WHEN totalsizeunits = 10 	  THEN 10
				WHEN totalsizeunits = 24 	  THEN 24
				WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
				WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
				WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
				WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
				WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
				WHEN totalsecondarysize = 0   THEN (servingsize*1) 
					END) AS g_totalsize
				FROM fmban_data) AS price_table) AS analysis_table
WHERE `definition` = "healthy"
;-- Healthy_food = 147, Unhealthy_food = 135, sample_size = 282

SELECT ROUND(AVG(price_per_calorie), 2) AS AVG_price_of_healthy_food
FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
		(CASE 
			WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
			WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
			WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
			WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
			WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
			WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
            WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
            WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
            WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
            WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
				AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			ELSE "unhealthy"
				END) AS `definition`
FROM (SELECT*, (CASE 
				WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
				WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
				WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 'G'     THEN (totalsize*1)
				WHEN totalsizeunits = 10 	  THEN 10
				WHEN totalsizeunits = 24 	  THEN 24
				WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
				WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
				WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
				WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
				WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
				WHEN totalsecondarysize = 0   THEN (servingsize*1) 
					END) AS g_totalsize
				FROM fmban_data) AS price_table) AS analysis_table
WHERE `definition` = "unhealthy"
; -- Sample mean = 3.59 for healthy food 

SELECT ROUND(STDDEV(price_per_calorie),2) AS STD_healthy_food_price
FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
		(CASE 
			WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
			WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
			WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
			WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
			WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
			WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
            WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
            WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
            WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
            WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
				AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			ELSE "unhealthy"
				END) AS `definition`
FROM (SELECT*, (CASE 
				WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
				WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
				WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 'G'     THEN (totalsize*1)
				WHEN totalsizeunits = 10 	  THEN 10
				WHEN totalsizeunits = 24 	  THEN 24
				WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
				WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
				WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
				WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
				WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
				WHEN totalsecondarysize = 0   THEN (servingsize*1) 
					END) AS g_totalsize
				FROM fmban_data) AS price_table) AS analysis_table
WHERE `definition` = "healthy"
; -- STD_healyhy_food_price = 8.68

/* Calculation t-statistic */

SELECT ROUND(((AVG(price_per_calorie)-3.74)/(STDDEV(price_per_calorie)/SQRT(147))),2) AS t_statistic
FROM (SELECT ID, category, subcategory, product, ROUND((price/(caloriesperserving*(g_totalsize/servingsize))),2) AS Price_per_calorie,
		(CASE 
			WHEN category = 'meat' 		  AND subcategory LIKE ('%pork%')      THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%ham%') 	   THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Frozen%')    THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%Processed%') THEN "unhealthy"
			WHEN category = 'meat' 		  AND product 	  LIKE ('%fat%') 	   THEN "unhealthy"
			WHEN category = 'NULL' 		  AND product 	  LIKE ('%organic%')   THEN "healthy"
			WHEN category = 'supplements' AND product     LIKE ('%detox%') 	   THEN "unhealthy"		
			WHEN category = 'meat' 		  AND vegan=1 						   THEN "healthy"
			WHEN category = 'meat' 		  AND paleofriendly=1 				   THEN "healthy"
			WHEN category = 'NULL' 	      AND vegan=1 						   THEN "healthy"
            WHEN category = 'supplements' AND organic=1 					   THEN "healthy"
            WHEN category = 'supplements' AND glutenfree=1 				       THEN "healthy"
            WHEN category = 'supplements' AND lowsodium=1 					   THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND subcategory LIKE ('%Tea%') 		THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product     LIKE ('%Cider%') 	THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND product 	   LIKE ('%Sauvignon%') THEN "healthy"
			WHEN category IN ('Beer', 'Beverages', 'Wine') AND organic=1 						THEN "healthy" 
            WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND organic=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND wholefoodsdiet=1 
				AND (glutenfree=1 OR lowfat=1 OR sugarconscious=1 OR lowsodium=1 OR organic=1) THEN "healthy"
			WHEN category IN ('Produce', 'Dairy and Eggs', 'Prepared Foods', 'Bread Rolls & Bakery', 'desserts', 'Frozen Foods') AND lowfat=1 
				AND (glutenfree=1 OR organic=1 OR sugarconscious=1 OR lowsodium=1 OR wholefoodsdiet=1) THEN "healthy"
			ELSE "unhealthy"
				END) AS `definition`
	FROM (SELECT*, (CASE 
				WHEN totalsizeunits = 'oz' 	  THEN (totalsize*28.35)
				WHEN totalsizeunits = 'fl oz' THEN (totalsize*28.35)
				WHEN totalsizeunits = 'g' 	  THEN (totalsize*1)
				WHEN totalsizeunits = 'G'     THEN (totalsize*1)
				WHEN totalsizeunits = 10 	  THEN 10
				WHEN totalsizeunits = 24 	  THEN 24
				WHEN totalsizeunits = 'lt' 	  THEN (totalsize*1000)
				WHEN totalsizeunits = 'NULL'  THEN (totalsize*1)
				WHEN totalsizeunits = 'unit'  THEN (totalsize*1)
				WHEN totalsizeunits = 'lb'    THEN (totalsize*453.59)
				WHEN totalsize 		=  0 	  THEN (totalsecondarysize*1)
				WHEN totalsecondarysize = 0   THEN (servingsize*1) 
					END) AS g_totalsize
				FROM fmban_data) AS price_table) AS analysis_table
WHERE `definition` = "healthy"
; -- t_statistic = -0.21

/*
	For simplicity (due that SQL-Server does not incorporate a lot of statistical functions.
	tinv is not present in SQL-Server) the calculation for the Cutoff value for the t_statistic 
    will be calculated using EXCEL and the formlula = -ABS(T.INV(alpha,(n-1))), the alpha used 
    is 0.05 because in this analyzis I am considering a 95% confidence level, therefore, 
    the final formula is =-ABS(T.INV(0.05,(147-1))) taking in to account alpha = 0.05 and n= 147 
                    
	RESULTING on a Cutoff Value for t_statistic of -1.66

/* Does the t_statistic falls in the rejection region ? */

/*
	The t_statistic = -0.21 does not falls in to the rejection region defined by the cutoff of 
    the t_statistic = -1.66 thus concluding according to this analysis that yes healthy food cost less:
Null Hypothesis = H0 (AVG price of healthy food < AVG price of all food) Not rejected --> Healthy food does cost less
*/
