-- BASE DE DATOS VIDEO.

-- extra - pais y nombre de los directores de cada pelicula

select d.nombre, pa.pais, p.titulo
from itc_pelicula p
inner join itc_director d on p.cve_dir = d.cve_d
inner join itc_paises pa on d.cve_pa = pa.cve_pa

-- extra - cantidad de peliculas realizadas en USA (EU)

select count(*) as total, pa.pais
from itc_pelicula p
inner join itc_paises pa on p.pais_prod = pa.cve_pa
where pa.pais = 'USA'
group by pa.pais

-- extra - cantidad de peliculas no realizadas en USA (EU)

select count(*) as total, pa.pais
from itc_pelicula p
inner join itc_paises pa on p.pais_prod = pa.cve_pa
where pa.pais != 'USA'
group by pa.pais

-- extra - Muestra el nombre de las peliculas "Romantica"
SELECT 
    p.titulo AS Pelicula,
    g.genero AS Genero
FROM itc_Pelicula p
INNER JOIN itc_genero g ON p.cve_ge = g.cve_g
WHERE g.genero = 'ROMANCE';


-- extra - Muestra todas las peliculas para niños
SELECT 
    p.titulo AS Pelicula,
    c.nombre AS Categoria
FROM itc_Pelicula p
INNER JOIN itc_Categoria c ON p.cve_categ = c.cve_cat
WHERE c.nombre = 'NIÑOS';


-- extra - Muestrame los nombres de los nombres de las peliculas mas rentadas
SELECT TOP 1 WITH TIES
    p.titulo AS Pelicula,
    COUNT(r.folio) AS Total_Rentas
FROM itc_Renta r
INNER JOIN itc_Pelicula p ON r.cve_p = p.cve_p
GROUP BY p.titulo
ORDER BY Total_Rentas DESC;


-- extra - Muestra el nombre del cliente, nombre de la eplicula que mas adeudos tiene
SELECT TOP 1 WITH TIES 
    c.nombre AS cliente, 
    p.titulo AS pelicula, 
    (r.dias * CAST(r.costoXdia AS DECIMAL(10,2))) AS adeudo
FROM itc_Renta r
INNER JOIN itc_Cliente c ON r.cve_c = c.cve_c
INNER JOIN itc_Pelicula p ON r.cve_p = p.cve_p
INNER JOIN itc_cat_devol d ON r.cve_devol = d.cve_devol
WHERE d.situacion = 'ESPERA'
ORDER BY adeudo DESC;

-- 1.- Obtener de que genero se han rentado más películas.  

select g.genero, count(*) as total_rentas
from itc_renta r
inner join itc_pelicula p on r.cve_p = p.cve_p
inner join itc_genero g on p.cve_ge = g.cve_g
group by g.genero
order by total_rentas desc;


-- 2.- Obtener de que director tenemos más películas.  

select d.nombre, count(*) as total_peliculas
from itc_pelicula p
inner join itc_director d on p.cve_dir = d.cve_d
group by d.nombre
order by total_peliculas desc;


-- 3.- Obtener que películas se rentan menos.  

select p.titulo, count(r.folio) as total_rentas
from itc_pelicula p
left join itc_renta r on p.cve_p = r.cve_p
group by p.titulo
having count(r.folio) = (
    select min(c) from (
        select count(r2.folio) as c
        from itc_pelicula p2
        left join itc_renta r2 on p2.cve_p = r2.cve_p
        group by p2.cve_p
    ) t
);


-- 4.- Obtener que películas se rentan más.  

select p.titulo, count(r.folio) as total_rentas
from itc_pelicula p
left join itc_renta r on p.cve_p = r.cve_p
group by p.titulo
having count(r.folio) = (
    select max(c) from (
        select count(r2.folio) as c
        from itc_pelicula p2
        left join itc_renta r2 on p2.cve_p = r2.cve_p
        group by p2.cve_p
    ) t
);


-- 5.- Obtener Cuanto ha pagado el cliente 'Hugo Duarte Miranda'  

select c.nombre, sum(convert(decimal(10,2), r.costoXdia) * r.dias) as total_pagado
from itc_renta r
inner join itc_cliente c on r.cve_c = c.cve_c
where c.nombre = 'HUGO DUARTE MIRANDA'
group by c.nombre;


-- 6.- Obtener los clientes que adeudan películas y de cuanto es su adeudo.  

select c.nombre, sum(convert(decimal(10,2), r.costoXdia) * r.dias) as adeudo
from itc_renta r
inner join itc_cliente c on r.cve_c = c.cve_c
inner join itc_cat_devol d on r.cve_devol = d.cve_devol
where d.situacion = 'ESPERA'
group by c.nombre;


-- 7.- Obtener el nombre y dirección del cliente que mas a rentado.  

select top 1 c.nombre, c.direccion, count(r.folio) as total_rentas
from itc_cliente c
inner join itc_renta r on c.cve_c = r.cve_c
group by c.nombre, c.direccion
order by total_rentas desc;


-- 8.- Que generos le gustan al cliente que mas renta.  

select distinct g.genero
from itc_renta r
inner join itc_cliente c on r.cve_c = c.cve_c
inner join itc_pelicula p on r.cve_p = p.cve_p
inner join itc_genero g on p.cve_ge = g.cve_g
where c.cve_c = (
    select top 1 c2.cve_c
    from itc_renta r2
    inner join itc_cliente c2 on r2.cve_c = c2.cve_c
    group by c2.cve_c
    order by count(r2.folio) desc
);


-- 9.- Obtener de que generos un director dice que dirige pero no tiene películas de tal genero
-- (géneros registrados sin ninguna película asociada)

select g.genero
from itc_genero g
left join itc_pelicula p on g.cve_g = p.cve_ge
where p.cve_p is null;


-- 10.- Que día tuve mas rentas?  

select top 1 fecha_prestamo, count(*) as total_rentas
from itc_renta
group by fecha_prestamo
order by total_rentas desc;


-- 11.- Del día que tuve mas rentas que clientes fueron y que películas rentaron?  

select c.nombre as cliente, p.titulo as pelicula
from itc_renta r
inner join itc_cliente c on r.cve_c = c.cve_c
inner join itc_pelicula p on r.cve_p = p.cve_p
where r.fecha_prestamo = (
    select top 1 fecha_prestamo
    from itc_renta
    group by fecha_prestamo
    order by count(*) desc
);


-- 12.- Obtener el nombre y el estatus (estreno, clasicas, antiguas, recientes) de las películas que se rentaron con el mismo precio.  

select p.titulo, e.situacion, r.costoXdia
from itc_renta r
inner join itc_pelicula p on r.cve_p = p.cve_p
inner join itc_estatus e on p.estatus = e.cve_es
where r.costoXdia in (
    select costoXdia
    from itc_renta
    group by costoXdia
    having count(*) > 1
)
order by r.costoXdia;


-- 13.- Cuanto pagaría un cliente por rentar 2 películas de estreno y 2 clasicas 3 y 4 días respectivamente?  

select
    (2 * (select convert(decimal(10,2), costoXdia) from itc_estatus where situacion = 'ESTRENO')  * 3)
  + (2 * (select convert(decimal(10,2), costoXdia) from itc_estatus where situacion = 'CLASICA')  * 4) as total_pagar;


-- 14.- Si se rentaran todas las películas en existencia cuanto dinero se recabaria en un día.  

select sum(p.existencia * convert(decimal(10,2), e.costoXdia)) as total_dia
from itc_pelicula p
inner join itc_estatus e on p.estatus = e.cve_es;


-- 15.- Obtener el país que tiene mas directores.  

select top 1 pa.pais, count(*) as total_directores
from itc_paises pa
inner join itc_director d on pa.cve_pa = d.cve_pa
group by pa.pais
order by total_directores desc;


-- 16.- Obtener los nombres de los directores del pais con más directores.  

select d.nombre
from itc_director d
inner join itc_paises pa on d.cve_pa = pa.cve_pa
where pa.cve_pa = (
    select top 1 pa2.cve_pa
    from itc_director d2
    inner join itc_paises pa2 on d2.cve_pa = pa2.cve_pa
    group by pa2.cve_pa
    order by count(*) desc
);


-- 17.- Obtener la dirección de los clientes que rentan menos.  

select c.nombre, c.direccion, count(r.folio) as total_rentas
from itc_cliente c
left join itc_renta r on c.cve_c = r.cve_c
group by c.nombre, c.direccion
having count(r.folio) = (
    select min(cnt) from (
        select count(r2.folio) as cnt
        from itc_cliente c2
        left join itc_renta r2 on c2.cve_c = r2.cve_c
        group by c2.cve_c
    ) t
);


-- 18.- Que películas se rentaron con los precios actuales.  

select distinct p.titulo
from itc_renta r
inner join itc_pelicula p on r.cve_p = p.cve_p
inner join itc_estatus e on p.estatus = e.cve_es
where r.costoXdia = e.costoXdia;


-- 19.- Obtener el total de renta de cada película.  

select p.titulo, sum(convert(decimal(10,2), r.costoXdia) * r.dias) as total_renta
from itc_pelicula p
left join itc_renta r on p.cve_p = r.cve_p
group by p.titulo;


-- 20.- El promedio de renta de los clientes.  

select avg(total) as promedio_renta
from (
    select c.cve_c, sum(convert(decimal(10,2), r.costoXdia) * r.dias) as total
    from itc_cliente c
    left join itc_renta r on c.cve_c = r.cve_c
    group by c.cve_c
) t;


-- 21.- De Que director se han rentado más películas?  

select top 1 d.nombre, count(r.folio) as total_rentas
from itc_renta r
inner join itc_pelicula p on r.cve_p = p.cve_p
inner join itc_director d on p.cve_dir = d.cve_d
group by d.nombre
order by total_rentas desc;


-- 22.- El cliente que mas renta de que generos renta?  

select top 1 g.genero, count(r.folio) as total
from itc_renta r
inner join itc_cliente c on r.cve_c = c.cve_c
inner join itc_pelicula p on r.cve_p = p.cve_p
inner join itc_genero g on p.cve_ge = g.cve_g
where c.cve_c = (
    select top 1 c2.cve_c
    from itc_renta r2
    inner join itc_cliente c2 on r2.cve_c = c2.cve_c
    group by c2.cve_c
    order by count(r2.folio) desc
)
group by g.genero
order by total desc;
