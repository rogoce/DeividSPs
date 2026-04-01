-- Verifica si lleva QR DRN#3066 JEPEREZ
-- Creado    : 20/04/2022 - Autor: Henry Giron--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro591;

create procedure sp_pro591(a_no_poliza char(10))
returning	integer		as resultado,
			varchar(30)	as descripcion;
			
define _no_unidad       char(5);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _cnt				smallint;
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);



set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc	
	return _error,		  
		   _error_desc;
end exception


--set debug file to "sp_pro590.trc";
--trace on;

select cod_ramo,cod_subramo
  into _cod_ramo, _cod_subramo
  from emipomae
 where no_poliza = a_no_poliza;
 
   let _cnt = 0;

if _cod_ramo = '002' then
    if _cod_subramo = '001' then
		 FOREACH
				select no_unidad
				  into _no_unidad
				  from emipouni
				 where no_poliza = a_no_poliza

				select count(*)
				  into _cnt
				  from emipocob	   
				 where no_poliza = a_no_poliza
				   and no_unidad = _no_unidad
				   and cod_cobertura in ('00104','00122','00907','01030','01141','01155','01481','01535');

				if _cnt > 0 then
					return 1,'APLICA' with resume;
					exit foreach;
				end if
		   END FOREACH
	   end if

else

	if _cod_ramo = '023' then
	
	 FOREACH
			select no_unidad
			  into _no_unidad
			  from emipouni
			 where no_poliza = a_no_poliza

			select count(*)
			  into _cnt
			  from emipocob	   
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and cod_cobertura in ('01301','01310','01341','01536','01657');

			if _cnt > 0 then
				return 1,'APLICA' with resume;
				exit foreach;
			end if

	   END FOREACH
   else
			if _cod_ramo = '020' then				
				select count(*)
				  into _cnt
				  from emipouni
				 where no_poliza = a_no_poliza						  
				   and cod_producto in ('04562','04561','05769','07229','07285');

				if _cnt > 0 then
					return 1,'APLICA' with resume;										
				end if					

		   end if
   end if
	
end if
IF _cnt IS NULL THEN
	LET _cnt = 0;
END IF
if _cnt = 0 then
	return 0,'NO APLICA' with resume;	
end if

end
end procedure;