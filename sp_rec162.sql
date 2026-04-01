-- Reporte de las Reservas Promedios del Ultimo Mes

-- Creado    : 07/07/2008 - Autor: Amado Perez  

drop procedure sp_rec162;

create procedure sp_rec162() 
returning integer,
          char(50);

define _periodo_rec	char(7);

select rec_periodo
  into _periodo_rec
  from parparam
 where cod_compania = "001";


foreach
 select
   into
   from recrepro
  where periodo = 

end procedure
