-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_end_cob_rea;
CREATE PROCEDURE ap_end_cob_rea() 
RETURNING  smallint,				--Salud
		   char(20);

DEFINE 	_no_poliza		    char(10);
DEFINE 	_no_endoso			char(5);
DEFINE 	_no_remesa			char(10);
DEFINE 	_renglon		    integer;
DEFINE  _error              integer;


SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

begin work;


begin
on exception set _error
    rollback work;
	return _error, "Error al Cambiar Tarifas...";
end exception


foreach 
	select no_poliza,
		   no_endoso
	  into _no_poliza,
		   _no_endoso
	  from tmp_end

	update endedmae 
	   set sac_asientos = 0 
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	update sac999:reacomp
	   set sac_asientos = 0
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso
	   and periodo = '2020-07';
end foreach

foreach
	select no_remesa,
	       renglon
	  into _no_remesa,
	       _renglon
	  from tmp_cob_copy
	
	update cobredet
	   set sac_asientos = 0
	 where no_remesa = _no_remesa;
	   
	update sac999:reacomp
	   set sac_asientos = 0
	 where no_remesa = _no_remesa
	   and periodo = '2020-07';	   
end foreach

end

commit work;
return 0, 'Actualizacion exitosa';
END PROCEDURE	  