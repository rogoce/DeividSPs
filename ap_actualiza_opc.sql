-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_actualiza_opc;
CREATE PROCEDURE ap_actualiza_opc() 
RETURNING  smallint,				--Salud
		   char(20);

DEFINE 	_no_poliza		    char(10);
DEFINE 	_no_unidad			char(5);
DEFINE 	_opcion				char(1);
DEFINE 	_no_documento		char(20);
DEFINE  _error              integer;
DEFINE  _notrx              integer;
DEFINE  _error_desc         varchar(50);


SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

--begin work;

begin
on exception set _error
--    rollback work;
	return _error, "Error al Cambiar Tarifas...";
end exception


foreach 
	select a.no_documento,
	       a.no_unidad,
		   a.opcion,
		   b.no_poliza_ant
	  into _no_documento,
	       _no_unidad,
		   _opcion,
		   _no_poliza
	  from deivid_tmp:tmp_opcion a, prdpreren b
	 where a.no_documento = b.no_documento
       and a.no_unidad = b.no_unidad
	   and b.renovada = 0
	   and b.actualizado = 0
	   and b.periodo = '2026-05'
	   
{	select a.no_documento,
	       a.no_unidad,
		   a.opcion,
		   b.no_poliza
	  into _no_documento,
	       _no_unidad,
		   _opcion,
		   _no_poliza
	  from deivid_tmp:tmp_opcion a, emipomae b
	 where a.no_documento = b.no_documento
	   and b.renovada = 0
	   and b.actualizado = 1
}	  
	update emiauto
	   set opcion = _opcion
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;
	   
	update prdpreren
       set procesado = 0, desc_error = "", pre_renovado = 0
	 where no_poliza_ant = _no_poliza
	   and no_unidad = _no_unidad
	   and periodo = '2026-05';
	  
end foreach
end

--commit work;
return 0, 'Actualizacion exitosa';
END PROCEDURE	  