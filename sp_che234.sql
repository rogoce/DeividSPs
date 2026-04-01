-- Realiza cambios de Enmoaut a Emiauto
-- Creado    : 06/04/2016 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_pro4955('877853','00004')
  
drop procedure sp_che234;
create procedure sp_che234()
returning char(20),smallint,smallint;
--int,			char(100);

define _error_desc,_mensaje		CHAR(100);
DEFINE _no_unidad       CHAR(5);
DEFINE _cod_tipoveh     CHAR(3);
DEFINE _uso_auto        CHAR(1);
define _error_isam		integer;
define _error			integer;
define _no_documento    char(20);
define a_no_poliza      char(10);
define _no_poliza       char(10);
define _no_endoso       char(5);
define _estatus,_cnt,_cnt2         smallint;
define _estaus_char     char(15);

set isolation to dirty read;

--set debug file to "sp_pro4955.trc";
--trace on;
--return _error, _error_desc;

BEGIN

	--Este ciclo fue para buscar estatus de las polizas en ancon
	{foreach
		select poliza
		  into _no_documento
		  from verificar
		  
		let a_no_poliza = sp_sis21(_no_documento);

		select estatus_poliza
		  into _estatus
		  from emipomae
		 where no_poliza = a_no_poliza;

		if _estatus = 1 then
			let _estaus_char = 'Vigente';
		elif _estatus = 2 then
			let _estaus_char = 'Cancelada';
		elif _estatus = 3 then
			let _estaus_char = 'Vencida';
		else	
			let _estaus_char = 'Anulada';
		end if	

		UPDATE verificar
		   SET estatusa = _estaus_char
		 WHERE poliza = _no_documento;

	end foreach}
	--Este ciclo es para cambiar la forma de pago a 092 DUC a las polizas proporcionadas por Ducruet	01/08/2016
	foreach
		select poliza
		  into _no_documento
		  from verificar2
		  
		let a_no_poliza = sp_sis21(_no_documento);

	{	UPDATE emipomae
		   SET cod_formapag = '092'
		 WHERE no_poliza = a_no_poliza;}
		 
		select count(*) into _cnt from cobtacre where no_documento = _no_documento;
		select count(*) into _cnt2 from cobcutas where no_documento = _no_documento;
		if _cnt > 0 or _cnt2 > 0 then
			return _no_documento,_cnt,_cnt2 with resume;
			
		end if

	end foreach
END
	
--return '0','Actualización Exitosa';
end procedure;