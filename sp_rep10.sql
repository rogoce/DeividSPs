DROP PROCEDURE "informix".sp_rep10;

CREATE PROCEDURE "informix".sp_rep10(
)RETURNING varchar(10),
           varchar(20),
		   varchar(10),
		   varchar(30);     

define _no_documento  varchar(20);
define _no_poliza     varchar(10);
define _cnt           smallint;
define _cnt_i         smallint;
define _cod_producto  varchar(5);
define _no_unidad     varchar(5);
define _cod_cobertura varchar(5);
define _tipo_poliza   smallint;
define _nuevo         smallint;
define _no_motor      varchar(30);
define _entro          smallint;
define _cotizacion    varchar(10);
  
SET ISOLATION TO DIRTY READ;
let _nuevo = 3;
	foreach
		select no_documento,
			   no_poliza,
			   cotizacion
		 into _no_documento,
			  _no_poliza,
			  _cotizacion
		  from emipomae  
		 where cod_ramo   = '002'
		   and fecha_suscripcion >= '01/01/2015'
		   AND actualizado     = 1
		   and nueva_renov  = 'N'
		   
		let _tipo_poliza = 1;
		
		 /*  select count(*)
		     into _cnt
			 from emipouni
			where no_poliza = _no_poliza;
				
		if _cnt = 1 then*/
		foreach
		    select cod_producto,
			       no_unidad
			  into _cod_producto,
				   _no_unidad
			  from emipouni
			 where no_poliza = _no_poliza
			
			foreach			
				select cod_cobertura
				  into _cod_cobertura
				  from emipocob
				 where no_poliza = _no_poliza
				  and no_unidad = _no_unidad
				   
					if _cod_cobertura = "00118" or _cod_cobertura = "00119" or _cod_cobertura = "00121" or _cod_cobertura = "00901" or _cod_cobertura = "00902" or _cod_cobertura = "00903" then
						let _tipo_poliza = 2; 
					end if
			end foreach
			if _tipo_poliza = 2 then
					-- debe entrar inspeccion
						select no_motor
						  into _no_motor
						  from emiauto
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad;
						 
						select nuevo
						  into _nuevo
						  from emivehic
						 where no_motor = trim(_no_motor);
						
						if _nuevo = 0 then
							-- debe entrar inspeccion
							select count(*) 
							  into _cnt_i
							  from insp_cot_pend
							 where no_motor = trim(_no_motor);
							 
								if _cnt_i > 0 then
									let _tipo_poliza = 1; 
								end if
						else 
							let _tipo_poliza = 1; 
						End If 
			end if
		--end if
		end foreach
		if _tipo_poliza = 1 then
			continue foreach;
		end if
		
			RETURN
			_no_poliza,
			_no_documento,
			_cotizacion,
			_no_motor
			WITH RESUME;
	end foreach
END PROCEDURE;