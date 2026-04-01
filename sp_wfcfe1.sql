-- Actualizacion de Emipomae proveniente de wf
-- 
-- Creado    : 20/05/2011 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - - ASEGURADORA ANCON, S.A.

DROP PROCEDURE sp_wfcfe1;
create procedure sp_wfcfe1(
a_no_poliza	    	char(10),
a_wf_aprob	    	smallint,
a_wf_firma_aprob 	char(20),
a_wf_incidente	    integer,
a_wf_no_endoso      char(5),
a_wf_fecha_entro    datetime hour to minute,
a_wf_observacion    varchar(255),
a_wf_no_doc         char(20),
a_tipo              char(12),
a_wf_cod_ramo       char(3),
a_wf_cod_subramo    char(3),
a_cod_contratante   char(10),
a_wf_firma_real 	char(20),
a_wf_vig_can        smallint default 0)

returning integer;

define _error	integer;
define a_wf_fecha_aprob datetime hour to minute;
define _usuario,_usuario2 char(8);
define _emis_firma_aut	  smallint;
define _actualizado   	  smallint;
define _tipo              smallint;
define _cant1             integer;
define _cant2             integer;
define _usuario_end       char(8);
define _desc_error        char(255);
define _no_endoso         char(5);

set isolation to dirty read;

begin
on exception set _error
	return _error;
end exception

if a_no_poliza = '2046706' then
SET DEBUG FILE TO "sp_wfcfe1.trc";
TRACE ON;
end if

--if a_no_poliza = '2046706' and a_wf_no_endoso = '00003' then
--	return _error;
--end if
	

let _actualizado = 0;
let _error = 0;

if a_wf_no_endoso = "00000" then
	select actualizado
	  into _actualizado
	  from emipomae
	 where no_poliza = a_no_poliza;
else
	select actualizado, user_added
	  into _actualizado, _usuario_end
	  from endedmae
	 where no_poliza       = a_no_poliza
	   and no_endoso       = a_wf_no_endoso;
end if

if _actualizado = 1 then
	return 0;
end if

let a_wf_fecha_aprob = current;
let _emis_firma_aut  = 0;

if a_wf_aprob = 1 then		--Aprobo
	let a_wf_aprob = 2;
elif a_wf_aprob = 0 then 	--Rechazado
	let a_wf_aprob = 3;
end if

if a_wf_aprob = 3 then
	let a_wf_vig_can = 2;
else
	if a_wf_vig_can = 0 then 	--Cancelado
		let a_wf_vig_can = 3;
	end if
end if

select usuario
  into _usuario
  from insuser
 where windows_user = a_wf_firma_aprob;

let a_wf_firma_aprob = _usuario;

--Saber si el que aprobo, tiene firma

select usuario,
       emis_firma_aut
  into _usuario2,
       _emis_firma_aut
  from insuser
 where windows_user = a_wf_firma_real;

if _emis_firma_aut = 1 then
	let a_wf_firma_aprob = _usuario2;
end if


if a_wf_no_endoso = "00000" then

	update emipomae
	   set wf_aprob  	   = a_wf_aprob,
	       wf_firma_aprob  = a_wf_firma_aprob,
		   wf_incidente	   = a_wf_incidente,
		   wf_fecha_aprob  = a_wf_fecha_aprob
	 where no_poliza       = a_no_poliza;
else
	update endedmae
	   set wf_aprob  	   = a_wf_aprob,
	       wf_firma_aprob  = a_wf_firma_aprob,
		   wf_incidente	   = a_wf_incidente,
		   wf_fecha_aprob  = a_wf_fecha_aprob
	 where no_poliza       = a_no_poliza
	   and no_endoso       = a_wf_no_endoso;

end if

if a_wf_aprob = 3 then	--user rechazo

	INSERT INTO wfcferec(
	fecha_entro,
	fecha_rechazo,
	observacion,
	user_rechazo,
	no_documento,
	tipo,
	cod_ramo,
	cod_subramo,
	cod_contratante,
	status,
    incidente
	)
	VALUES(
	a_wf_fecha_entro,
	a_wf_fecha_aprob,
	a_wf_observacion,
    a_wf_firma_real,
    a_wf_no_doc,
	a_tipo,
	a_wf_cod_ramo,    
	a_wf_cod_subramo, 
	a_cod_contratante,
	"R",
	a_wf_incidente
    );
end if

if a_wf_aprob = 2 then	--Aprobo

	if a_wf_observacion is null then
	   let a_wf_observacion	= "";
	end if

	INSERT INTO wfcferec(
	fecha_entro,
	fecha_rechazo,
	observacion,
	user_rechazo,
	no_documento,
	tipo,
	cod_ramo,
	cod_subramo,
	cod_contratante,
	status,
	incidente
	)
	VALUES(
	a_wf_fecha_entro,
	a_wf_fecha_aprob,
	a_wf_observacion,
    a_wf_firma_real,
    a_wf_no_doc,
	a_tipo,
	a_wf_cod_ramo,    
	a_wf_cod_subramo, 
	a_cod_contratante,
	"A",
	a_wf_incidente
    );
end if

let _cant1 = 0;
let _cant2 = 0;

select count(*) 
  into _cant1
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_wf_no_endoso
   and cod_endomov = "003";		  --Endoso de rehabilitacion

select count(*)
  into _cant2
  from coboutleg
 where no_poliza = a_no_poliza;

if _cant1 > 0 and _cant2 > 0 then
--ejecutar procedure sp_cob337
	call sp_cob337(a_wf_no_doc, a_wf_vig_can, _usuario_end) returning _error, _desc_error, _no_endoso;
end if


end

return _error;

end procedure
