-- Genera Cheque ACH
-- Creado    : 08/06/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE ap_rev_sac113_rea;
CREATE PROCEDURE ap_rev_sac113_rea() 
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
select distinct sac_notrx  
into _notrx
from sac999:reacompasie
where no_registro in (
select no_registro from sac999:reacomp a, endedmae b
where a.no_poliza = b.no_poliza
and a.no_endoso = b.no_endoso
and b.no_factura in (
'01-3003727',
'01-3007315',
'01-3007463',
'01-3009007',
'01-3009421',
'01-3010143',
'01-3010386',
'01-3010946',
'01-3010952',
'01-3011048',
'01-3011234',
'01-3011235',
'01-3011346',
'01-3011748',
'01-3011753',
'01-3011754',
'01-3011842',
'10-88499'
))
and cuenta[1,3] = '511'	

{	select notrx
	  into _notrx
	  from tmp_sac113
	 where procesado = 0
	-- and notrx = 1539559
}
	call sp_sac77rea(_notrx) returning _error, _error_desc;
	
	{if _error = 0 then
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
    end if}	  
	return _error, _error_desc with resume;
end foreach
end

--commit work;
return 0, 'Actualizacion exitosa';
END PROCEDURE	  