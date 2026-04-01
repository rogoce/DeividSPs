--**********************************
-- Reporte para sacar los siniestros pagados de enero a sept 2011 para Leiry
-- *********************************
-- fecha: 07/11/2011

DROP PROCEDURE sp_aud25;
CREATE PROCEDURE sp_aud25()
RETURNING   CHAR(20),  
			varchar(100),
			char(18),
			date,
			DEC(16,2);

define _no_documento	char(20);
define _cod_cliente     char(10);
DEFINE _sin_pag_aa      DEC(16,2);
define _nombre_cli      varchar(100);
define _direccion_1	    varchar(50);
define _direccion_2	    varchar(50);
define _fecha_ult_pago 	date;
define _no_poliza       char(10);
define _filtros         varchar(255);
define _numrecla       	char(18);
define _no_reclamo      char(10);
define _fecha_reclamo   date;

 
SET ISOLATION TO DIRTY READ;

let _sin_pag_aa = 0;

let	_nombre_cli  = "";


call sp_rec01('001', '001', '2011-10', '2011-10') returning _filtros;

foreach
 select doc_poliza,
        pagado_bruto,
        numrecla,
        cod_cliente,
        no_reclamo   
   into _no_documento,
        _sin_pag_aa,
		_numrecla,
		_cod_cliente,
		_no_reclamo
   from tmp_sinis
  where seleccionado = 1


  select nombre
    into _nombre_cli
	from cliclien
   where cod_cliente = _cod_cliente;

  select fecha_reclamo
    into _fecha_reclamo
	from recrcmae
   where no_reclamo = _no_reclamo;


  RETURN _no_documento,
		 _nombre_cli,
		 _numrecla,
		 _fecha_reclamo,
		 _sin_pag_aa
    	 WITH RESUME;

END FOREACH

drop table tmp_sinis;

END PROCEDURE
  