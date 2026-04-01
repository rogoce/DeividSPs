-- Procedimiento para convertir polizas de AUTOMOVIL a AUTOMOVIL FLOTA --
-- 
-- Creado    : 18/08/2014 - Autor: Amado Perez Mendoza.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis198d;

create procedure "informix".sp_sis198d()
returning integer, 
          char(100),
          char(30);
		  	
define _no_poliza      char(10); 
define _no_endoso	   char(5);
define _no_unidad      char(5);
define _cod_subramo    char(3);
define _valor_flota    varchar(10);
define _cod_producto   char(5);
define _cod_cobertura  char(5);
define _cod_cober_reas char(3);
define _orden          smallint;
define _cod_contrato         char(5);
define _porc_partic_suma     decimal(9,6);
define _porc_partic_prima    decimal(9,6);

define _cod_coasegur         char(3);
define _porc_partic_reas     decimal(9,6);
define _porc_comis_fac       decimal(7,4);
define _porc_impuesto        decimal(5,2);
define _suma_asegurada       decimal(16,2);
define _prima                decimal(16,2);

define _impreso              smallint;
define _fecha_impresion      date;
define _no_cesion            char(10);
define _subir_bo             smallint;
define _monto_comision       decimal(16,2);
define _monto_impuesto       decimal(16,2);


define _no_remesa            char(10);
define _renglon              smallint;
define _cod_compania         char(3);
define _cod_sucursal         char(3);
define _no_tranrec           char(10);
define _cod_recibi_de        char(10);
define _no_reclamo, _no_reclamo2           char(10);
define _no_recibo            char(10);
define _doc_remesa           char(30);
define _tipo_mov             char(1);
define _monto                decimal(16,2);
define _prima_neta           decimal(16,2);
define _impuesto             decimal(16,2);
define _monto_descontado     decimal(16,2);
define _comis_desc           smallint;
define _desc_remesa          varchar(100,0);
define _saldo                decimal(16,2);
define _periodo              char(7);
define _fecha                date;
define _actualizado          smallint;
define _cod_agente           char(5);
define _cod_auxiliar         char(5);
define _sac_asientos         smallint;
define _flag_web_corr        smallint;
define _no_recibo2           char(10);
define _gastos_manejo        decimal(16,2);
define _cod_ruta             char(5);
define a_documento CHAR(20);

define _error_cod	integer;
define _error_isam	integer;
define _error_desc	char(100);
define _no_motor    varchar(30);
define _cnt         integer;
define _no_cambio   smallint; 


set isolation to dirty read;

BEGIN WORK;

begin 
on exception set _error_cod, _error_isam, _error_desc
    rollback work;
	return _error_cod, _error_desc, _error_desc;
end exception

--SET DEBUG FILE TO "sp_sis198.trc"; 
--trace on;

foreach	with hold
 select no_documento,
        cod_ramo
   into a_documento,
        _cod_subramo
   from tmp_autoflota3
  where procesado = 0

	foreach with hold
	 select no_poliza
	   into _no_poliza
	   from emipomae
	  where no_documento = a_documento

	 let _valor_flota = null;

	 select valor_flota
	   into _valor_flota
	   from parautflot
	  where tipo_valor = "cod_subramo"
	    and valor_auto = _cod_subramo;

	 if _valor_flota is not null and TRIM(_valor_flota) <> "" then
		 update emipomae 
		    set cod_subramo = _valor_flota
		  where no_poliza   = _no_poliza;

         update tmp_autoflota3
		    set procesado = 1
		  where no_documento = a_documento;
	 else
	    rollback work;
		return -1, "cod_subramo",_cod_subramo;
	 end if
	 end foreach
end foreach   	  	
end

COMMIT WORK;

let _error_cod  = 0;
let _error_desc = "Proceso Completado ...";

return _error_cod, _error_desc,"";

end procedure;
