-- Procedimiento que devuelve el ultimo dia del mes dado el periodo
--
-- Creado    : 13/02/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/02/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis36bk3;

CREATE PROCEDURE "informix".sp_sis36bk3(a_no_aviso char(10)) 
RETURNING varchar(50),char(20);

DEFINE _cod_asegurado char(10);
DEFINE _no_poliza char(10);
DEFINE _nombre_acreedor varchar(50);
define _leasing         smallint;
define _no_documento    char(20);

-- Descomponer los periodos en fechas

foreach

select no_poliza,no_documento
  into _no_poliza,_no_documento
  from avisocanc
 where no_aviso = a_no_aviso
   and nombre_acreedor[1,7] = '... SIN'
  
    select leasing
	  into _leasing
	  from emipomae
	 where no_poliza = _no_poliza;
	 
    if _leasing = 1 then
		foreach
			select cod_asegurado
			  into _cod_asegurado
			  from emipouni
			 where no_poliza = _no_poliza
			 
			select nombre
			  into _nombre_acreedor
			  from cliclien
			 where cod_cliente = _cod_asegurado;

			update avisocanc
			  set nombre_acreedor = _nombre_acreedor
			 where no_aviso   = a_no_aviso
			   and no_poliza = _no_poliza;
			 
			exit foreach;		
		end foreach
		 
		return _nombre_acreedor, _no_documento with resume;  
	else
		continue foreach;
	end if
	
	let _nombre_acreedor = ''; 
end foreach


END PROCEDURE;