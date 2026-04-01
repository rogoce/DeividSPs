-- Procedimiento que verifica los sac_notrx con distintos tipos de origen
-- 
-- Creado    : 11/10/2010 - Autor: Armando Moreno M.
--
drop procedure sp_sac161a;		
create procedure sp_sac161a()
returning smallint, 
          varchar(100);
		  	
define _res_notrx,_no_poliza		char(10);
define _cnt_origen		smallint;
define _no_documento    char(20);


set isolation to dirty read;

begin 

--PUESTO POR ARMANDO TEMPORALMENTE
 update emipoliza
    set fecha_suspension = null
where cod_grupo in('78033','78032','78034');

let _cnt_origen = 0;
foreach
	select res_notrx,
	       count(*)
	  into _res_notrx,
	       _cnt_origen
	  from (select distinct res_notrx,res_origen 
	          from cglresumen 
			 where res_fechatrx >= '01/01/2024' 
			   and res_notrx <> '1421724' 
			   and res_origen <> 'CGL')
	         group by 1
            having count(*) > 1
             order by res_notrx

    return 1,_res_notrx || _cnt_origen with resume;
end foreach

--No es necesario, ya se valida en el sp_pro177
{foreach
	select emi.no_documento,
	       emi.no_poliza
	  into _no_documento,
	       _no_poliza
	  from emipomae emi
	  left join endedmae mae on mae.no_poliza = emi.no_poliza
     	   and mae.no_endoso = '00000'
	 where mae.no_factura is null
	   and emi.estatus_poliza = 1
	   and emi.actualizado = 1
	   
    return 1,_no_poliza ||" endosocero " || _no_documento with resume;
end foreach}

end 

return 0, 'Proceso Completado.';
end procedure;

--Se debe reversar lo res_notrx