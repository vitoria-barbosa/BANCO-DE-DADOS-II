-- Atividade 1

-- 1. Categorias que possuam preços entre R$ 100,00 e R$ 200,00.
SELECT * FROM CATEGORIA WHERE valor_dia BETWEEN 100 AND 200;

-- 2. Categorias cujos nomes possuam a palavra ‘Luxo’.
SELECT * FROM CATEGORIA WHERE nome ILIKE '%LUXO%';

-- 3. Nomes de categorias de apartamentos que foram ocupados há mais de 5 anos.
SELECT c.nome FROM APTO a
JOIN HOSPEDAGEM h
ON h.num_quarto = a.num
JOIN CATEGORIA c 
ON a.cod_cat = c.cod_cat
WHERE EXTRACT(YEAR from dt_ent) < 2021;

-- 4. Apartamentos que estão ocupados, ou seja, a data de saída está vazia.
SELECT num, status, cod_cat FROM APTO a
JOIN HOSPEDAGEM h
ON h.num_quarto = a.num
WHERE dt_saida IS NULL;

-- 5. Apartamentos cuja categoria tenha código 1, 2, 3, 11, 34, 54, 24, 12.
SELECT * FROM APTO 
WHERE cod_cat IN (1, 2, 3, 11, 34, 54, 24, 12);

-- 6. Apartamentos cujas categorias iniciam com a palavra ‘Luxo’.
SELECT num, status, a.cod_cat 
FROM CATEGORIA c
JOIN APTO a
ON c.cod_cat = a.cod_cat
WHERE nome ILIKE 'LUXO%';

-- 7. Quantidade de apartamentos cadastrados no sistema.
SELECT COUNT(*) AS qtd_aptos FROM APTO;

-- 8. Somatório dos preços das categorias.
SELECT SUM(valor_dia) AS somatorio_preco FROM CATEGORIA;

-- 9. Média de preços das categorias.
SELECT ROUND(AVG(valor_dia), 2) AS media_precos FROM CATEGORIA;

-- 10. Maior preço de categoria.
SELECT MAX(valor_dia) AS maior_preco FROM CATEGORIA;

-- 11. Menor preço de categoria.
SELECT MIN(valor_dia) AS menor_preco FROM CATEGORIA;

-- 12. O preço média das diárias dos apartamentos ocupados por cada hóspede.
SELECT ROUND(AVG(valor_dia), 2) AS media_dia_hospede FROM APTO a
JOIN CATEGORIA c
ON a.cod_cat = c.cod_cat
JOIN HOSPEDAGEM h
ON h.num_quarto = a.num
GROUP BY h.cod_hosp;

-- 13. Quantidade de apartamentos para cada categoria.
SELECT cod_cat, COUNT(*) AS qtd_apto 
FROM APTO GROUP BY cod_cat 
ORDER BY cod_cat ASC;

-- 14. Categorias que possuem pelo menos 2 apartamentos.
SELECT c.cod_cat, c.nome, c.valor_dia, COUNT(*) AS qtd_aptos
FROM CATEGORIA c 
JOIN APTO a 
ON c.cod_cat = a.cod_cat
GROUP BY c.cod_cat
HAVING COUNT(*) >= 2;

-- 15. Nome dos hóspedes que nasceram após 1° de janeiro de 1970.
SELECT nome FROM HOSPEDE WHERE dt_nasc > '1970-01-01';

-- 16. Quantidade de hóspedes.
SELECT COUNT(*) AS qtd_hospedes FROM HOSPEDE;

-- 17. Apartamentos que foram ocupados pelo menos 2 vezes.
SELECT a.num, a.status, a.cod_cat, COUNT(*) AS qtd_vezes_ocupado
FROM HOSPEDAGEM h
JOIN APTO a 
ON h.num_quarto = a.num
GROUP BY a.num
HAVING COUNT(*) >= 2;

-- 18. Altere a tabela Hóspede, acrescentando o campo "Nacionalidade".
ALTER TABLE HOSPEDE ADD COLUMN nacionalidade VARCHAR(15);

-- 19.Quantidade de hóspedes para cada nacionalidade.
SELECT COUNT(cod_hosp) AS qtd_hosp_por_nacionalidade 
FROM HOSPEDE GROUP BY nacionalidade 
HAVING nacionalidade IS NOT NULL; 

-- 20. A data de nascimento do hóspede mais velho.
SELECT dt_nasc FROM HOSPEDE WHERE dt_nasc = (SELECT MIN(dt_nasc) FROM HOSPEDE);

-- 21. A data de nascimento do hóspede mais novo.
SELECT dt_nasc FROM HOSPEDE WHERE dt_nasc = (SELECT MAX(dt_nasc) FROM HOSPEDE);

-- 22. Reajuste em 10% o valor das diárias das categorias.
UPDATE CATEGORIA SET valor_dia = valor_dia * 1.1;

-- 23. O nome das categorias que não possuem apartamentos.
SELECT c.nome FROM CATEGORIA c
LEFT JOIN APTO a
ON c.cod_cat = a.cod_cat
WHERE a.num IS NULL;

-- 24. O número dos apartamentos que nunca foram ocupados.
SELECT a.num FROM APTO a 
LEFT JOIN HOSPEDAGEM h 
ON a.num = h.num_quarto
WHERE cod_hospedagem IS NULL;

-- 25. O número do apartamento mais caro ocupado pelo João.
SELECT a.num FROM HOSPEDAGEM h 
JOIN HOSPEDE ho
ON h.cod_hosp = ho.cod_hosp
JOIN APTO a
ON h.num_quarto = a.num
JOIN CATEGORIA c
ON a.cod_cat = c.cod_cat
WHERE ho.nome = 'João'
ORDER BY(valor_dia) DESC 
LIMIT 1;

-- 26. O nome dos hóspedes que nunca se hospedaram no apartamento 201.
SELECT nome FROM HOSPEDE
EXCEPT
SELECT ho.nome FROM HOSPEDAGEM h 
JOIN HOSPEDE ho
ON h.cod_hosp = ho.cod_hosp
JOIN APTO a
ON h.num_quarto = a.num
JOIN CATEGORIA c
ON a.cod_cat = c.cod_cat
WHERE h.num_quarto = 201;

-- 27. O nome dos hóspedes que nunca se hospedaram em apartamentos da categoria LUXO.
SELECT nome FROM HOSPEDE
EXCEPT
SELECT ho.nome FROM HOSPEDAGEM h 
JOIN HOSPEDE ho
ON h.cod_hosp = ho.cod_hosp
JOIN APTO a
ON h.num_quarto = a.num
JOIN CATEGORIA c
ON a.cod_cat = c.cod_cat
WHERE c.nome = 'LUXO';

-- 28. O nome dos hóspedes que se hospedaram ou reservaram apartamento do tipo LUXO.
SELECT ho.nome FROM HOSPEDAGEM h 
JOIN HOSPEDE ho
ON h.cod_hosp = ho.cod_hosp
JOIN APTO a
ON h.num_quarto = a.num
JOIN CATEGORIA c
ON a.cod_cat = c.cod_cat
WHERE c.nome = 'LUXO'
UNION
SELECT h.nome FROM RESERVA r 
JOIN HOSPEDE h
ON r.cod_hosp = h.cod_hosp
JOIN APTO a
ON r.num_quarto = a.num
JOIN CATEGORIA c
ON a.cod_cat = c.cod_cat
WHERE c.nome = 'LUXO';

-- 29. O nome dos hóspedes que se hospedaram mas nunca reservaram apartamentos do tipo LUXO.
SELECT ho.nome FROM HOSPEDAGEM h 
JOIN HOSPEDE ho
ON h.cod_hosp = ho.cod_hosp
JOIN APTO a
ON h.num_quarto = a.num
JOIN CATEGORIA c
ON a.cod_cat = c.cod_cat
WHERE c.nome = 'LUXO'
EXCEPT
SELECT h.nome FROM RESERVA r 
JOIN HOSPEDE h
ON r.cod_hosp = h.cod_hosp
JOIN APTO a
ON r.num_quarto = a.num
JOIN CATEGORIA c
ON a.cod_cat = c.cod_cat
WHERE c.nome = 'LUXO';

-- 30. O nome dos hóspedes que se hospedaram e reservaram apartamento do tipo LUXO.
SELECT ho.nome FROM HOSPEDAGEM h 
JOIN HOSPEDE ho
ON h.cod_hosp = ho.cod_hosp
JOIN APTO a
ON h.num_quarto = a.num
JOIN CATEGORIA c
ON a.cod_cat = c.cod_cat
WHERE c.nome = 'LUXO'
INTERSECT
SELECT h.nome FROM RESERVA r 
JOIN HOSPEDE h
ON r.cod_hosp = h.cod_hosp
JOIN APTO a
ON r.num_quarto = a.num
JOIN CATEGORIA c
ON a.cod_cat = c.cod_cat
WHERE c.nome = 'LUXO';

SELECT * FROM HOSPEDE;
SELECT * FROM APTO;
SELECT * FROM CATEGORIA;
SELECT * FROM FUNCIONARIO;
SELECT * FROM  HOSPEDAGEM;
SELECT * FROM RESERVA;