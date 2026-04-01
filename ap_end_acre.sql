-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_end_acre;
CREATE PROCEDURE ap_end_acre(a_cod_acreedor CHAR(5)) 
RETURNING  smallint,				--Salud
           char(10),
		   char(20);

DEFINE 	_no_poliza		    char(10);
DEFINE 	_no_endoso			char(5);
DEFINE 	_no_remesa			char(10);
DEFINE 	_renglon		    integer;
DEFINE  _error              integer;
DEFINE  _notrx              integer;
DEFINE  _error_desc         varchar(50);
DEFINE  _no_documento       CHAR(20);


SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;

begin work;

begin
on exception set _error
    rollback work;
	return _error, _no_endoso, _error_desc;
end exception

if a_cod_acreedor = '01229' then
	foreach 
		select no_documento
		  into _no_documento
		  from tmp_multicredit
		 where procesado = 0

		call sp_pro600(_no_documento) returning _error, _no_endoso, _error_desc;
		
		if _error = 0 then
			update tmp_multicredit
			   set procesado = 1
			 where no_documento = _no_documento;
		end if	   
	end foreach
elif a_cod_acreedor = '02412' then	
	foreach 
		select no_documento
		  into _no_documento
		  from tmp_banisi
		 where procesado = 0

		call sp_pro601(_no_documento) returning _error, _no_endoso, _error_desc;
		
		if _error = 0 then
			update tmp_multicredit
			   set procesado = 1
			 where no_documento = _no_documento;
		end if	   
	end foreach
end if
end

commit work;
return 0, NULL, 'Actualizacion exitosa';
END PROCEDURE	  