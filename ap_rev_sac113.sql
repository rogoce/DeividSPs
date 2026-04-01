-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_rev_sac113;
CREATE PROCEDURE ap_rev_sac113() 
RETURNING  smallint,				--Salud
		   char(20);

DEFINE 	_no_poliza		    char(10);
DEFINE 	_no_endoso			char(5);
DEFINE 	_no_remesa			char(10);
DEFINE 	_renglon		    integer;
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
	select notrx
	  into _notrx
	  from tmp_sac113
	 where procesado = 0

	call sp_sac77cob(_notrx) returning _error, _error_desc;
	
	if _error = 0 then
		update tmp_sac113
		   set procesado = 1,
			   error = _error,
			   descripcion = _error_desc
		 where notrx = _notrx;
	else
		update tmp_sac113
		   set error = _error,
			   descripcion = _error_desc
		 where notrx = _notrx;
    end if	   
end foreach
end

--commit work;
return 0, 'Actualizacion exitosa';
END PROCEDURE	  