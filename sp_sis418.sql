--- Actualizar el codigo de tipo de tarifa a las nuevas y renovadas
--- Creado 28/07/2014 por Armando Moreno

drop procedure sp_sis418;

create procedure "informix".sp_sis418()
returning char(20), char(10);

begin

define _cod_producto  	char(5);
define _cod_ramo    	char(3);
define _no_unidad       char(5);
define _tipo            smallint;
define _cnt, _cnt2             integer;
define _nueva_renov     char(1);
define _no_documento    char(20);
define _no_poliza       char(10);


--SET DEBUG FILE TO "sp_pro316.trc"; 
--TRACE ON;                                                                


set isolation to dirty read;

let _tipo = 0;

foreach
select cod_ramo,
       nueva_renov,
	   no_documento,
	   no_poliza
  into _cod_ramo,
	  _nueva_renov,
	  _no_documento,
	  _no_poliza
  from emipomae
 where fecha_suscripcion > "28/07/2014"
   and cod_ramo = '002'
   and nueva_renov = "R"


foreach

	select no_unidad,
	       cod_producto
	  into _no_unidad,
	       _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza

	let _tipo = sp_proe75(_no_poliza,_no_unidad);
	 
	if _tipo = 1 or _tipo = 2 or _tipo = 3 then  --Es sedan, suv o pickup
				
		SELECT count(*)
	      INTO _cnt
		  FROM prdcobpd p, emipocob e
		 WHERE p.cod_cobertura = e.cod_cobertura
		   AND p.cod_producto  = _cod_producto
		   AND p.tipo_descuento in (1,2)
		   AND e.no_poliza = _no_poliza
		   AND e.no_unidad = _no_unidad;

	   if _cnt > 0 then

            select count(*)
			  into _cnt2
			 from emipouni
			 where no_unidad = _no_unidad
			   and cod_tipo_tar = '001';

            if _cnt2 > 0 then
			  return _no_documento,	_no_poliza with resume;
			end if
			   	
	   end if

	end if

end foreach
end foreach
end 

end procedure;
