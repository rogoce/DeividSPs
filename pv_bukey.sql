drop procedure pv_buscar_llave; 

CREATE PROCEDURE "informix".pv_buscar_llave( tabla char(18))
RETURNING  char(18);
define indice char(18);         
define num_tabla integer;
define nombre_column char(18);
define p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16 integer;

--Creacion de tabla temporal donde se almacenan las llaves primarias
create temp table columnas_pri (tabla_nom char(18), columna char(18));

--Buscar el numero de identificacion de la tabla en el catalogo
select tabid into num_tabla from systables where tabname = tabla;

--Buscar el elemento que representa el indice de la llave primaria
foreach
select idxname into indice
  from sysconstraints where tabid = num_tabla
   and constrtype = "P"

   --Buscar los numero de partes o columnas que corresponde a la llave primaria
   select part1, part2, part3, part4, part5, part6, part7, part8,
          part9, part10, part11, part12, part13, part14, part15, part16
     into p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16
     from sysindexes
    where idxname = indice;

   --Buscar el nombre de las columnas que corresponden a la llave primaria
   if p1 != 0  then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p1); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if
   if p2 != 0  then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p2) ; 
      insert into columnas_pri values(tabla,  nombre_column);
   end if
   if p3 !=0 then         
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p3); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if
   if p4 !=0  then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p4); 
      insert into columnas_pri values (tabla,  nombre_column);
   end if
   if p5 !=0 then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p5); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if
   if p6 !=0 then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p6); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if
   if p7 !=0 then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p7); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if

   if p8 !=0 then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p8); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if

   if p9 !=0 then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p9); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if

   if p10 !=0 then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p10); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if

   if p11 !=0 then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p11); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if

   if p12 !=0 then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and  colno = abs(p12); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if

   if p13 !=0 then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p13); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if

   if p14 !=0 then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p14); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if

   if p15 !=0 then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p15); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if

   if p16 !=0  then
      select colname into nombre_column from syscolumns
       where tabid = num_tabla
         and colno = abs(p16); 
      insert into columnas_pri values(tabla,  nombre_column);
   end if
end foreach;

--Retornar los nombres de las columas que corresponden a la llave primaria
foreach select columna into nombre_column   from columnas_pri
 where tabla_nom = tabla
   return nombre_column with resume;
end foreach;
drop table columnas_pri;
END PROCEDURE ;


 

