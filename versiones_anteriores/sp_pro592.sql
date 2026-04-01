-- Verifica si lleva QR DRN#3066 JEPEREZ
-- Creado    : 20/04/2022 - Autor: Henry Giron--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro592;

create procedure sp_pro592(a_no_poliza char(10), a_endoso CHAR(5) DEFAULT '*', a_unidad CHAR(255) DEFAULT '*')
returning	integer		as resultado,
			varchar(30)	as descripcion;
			
define _no_unidad       char(5);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _cnt				smallint;
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
 define v_filtros           varchar(255);
	define _tipo	           char(1);


set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc	
	return _error,		  
		   _error_desc;
end exception


--set debug file to "sp_pro590.trc";
--trace on;
drop table if exists tmp_codigos;


	LET v_filtros     = "";
IF a_unidad <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||" No.unidad: "||TRIM(a_unidad);
	LET _tipo = sp_sis04(a_unidad); -- Separa los valores del String
--	DROP TABLE tmp_codigos;
else
	create temp table tmp_codigos(
	codigo	char(25)  not null,
	primary key (codigo)) with no log;
	insert into tmp_codigos(codigo)
	select trim(no_unidad)
	  from emipouni
     where no_poliza = a_no_poliza;	
END IF

IF a_endoso <> "*" and TRIM(a_endoso) <> '00000'  THEN

	 select count(*)
	   into _cnt
	   FROM endedmae a, endeduni b 
	  WHERE a.no_poliza = b.no_poliza
  	    AND a.no_endoso = b.no_endoso
	    and b.no_poliza = a_no_poliza
	    and b.no_endoso = a_endoso
		and cod_endomov in ('004');
		
		IF _cnt IS NULL THEN
			LET _cnt = 0;
		END IF
		
		if _cnt = 0 then
		    --DROP TABLE tmp_codigos;
			--return 0,'NO APLICA' with resume;	
			delete from tmp_codigos;
		else				
			
			delete from tmp_codigos
			 where trim(codigo) not in ( 
			 select distinct trim(b.no_unidad )
			  FROM endedmae a, endeduni b 
			 WHERE a.no_poliza = b.no_poliza
			   AND a.no_endoso = b.no_endoso
			   and b.no_poliza = a_no_poliza
				and b.no_endoso = a_endoso
				and cod_endomov in ('004') );
		end if				
END IF

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
				 and no_unidad IN (SELECT codigo FROM tmp_codigos )

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
			 and no_unidad IN (SELECT codigo FROM tmp_codigos )

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
				 and no_unidad IN (SELECT codigo FROM tmp_codigos )
				   and cod_producto in ('04562','04561','05769','07229','07285');

				if _cnt > 0 then
					return 0,'NO APLICA' with resume;															
				else
				    LET _cnt = 1;
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