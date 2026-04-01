-- Endoso Especial de Exclusion

-- Creado    : 03/10/2011 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro1007;

CREATE PROCEDURE "informix".sp_pro1007(a_no_poliza char(10))
returning varchar(100),date,char(20),char(100),char(100),varchar(100),decimal(16,2);


define _nombre			varchar(100);
define _cod_contratante char(10);
define _cod_aseg        char(10);
define _no_documento    char(20);
define _vigencia_inic   date;
define _fecha_actual    char(100);
define _fecha           date;
define _vigencia_inic_c char(100);
define _nombre_aseg     varchar(100);
define _prima_bruta     decimal(16,2);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro1007.trc";
--trace on;

let _fecha = current;
let _prima_bruta = 0.00;

BEGIN

select no_documento,
       vigencia_inic,
	   cod_contratante,
	   prima_bruta
  into _no_documento,
	   _vigencia_inic,
	   _cod_contratante,
	   _prima_bruta
  from emipomae
 where no_poliza = a_no_poliza;


select nombre
  into _nombre
  from cliclien
 where cod_cliente = _cod_contratante;

foreach

   select cod_asegurado
     into _cod_aseg
	 from emipouni
	where no_poliza = a_no_poliza

	select nombre
	  into _nombre_aseg
	  from cliclien
	 where cod_cliente = _cod_aseg;

   exit foreach;

end foreach

call sp_sis20(_fecha) returning _fecha_actual;
call sp_sis20(_vigencia_inic) returning _vigencia_inic_c;

return _nombre,
	   _vigencia_inic,
	   _no_documento,
	   _fecha_actual,
	   _vigencia_inic_c,
	   _nombre_aseg,
	   _prima_bruta;

END
END PROCEDURE
