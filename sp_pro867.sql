-- Ingreso a parmailsend para ser enviado por correo
-- CARTA DE POLIZA NUEVA Y RENOVACION
-- ANGEL TELLO 04/12/2013
--se excluye coas min  Armando, 14/04/2015
--execute procedure sp_pro867('','N')


drop procedure sp_pro867;
create procedure sp_pro867(a_no_poliza char(10), a_nueva_renov char(1))
returning	smallint,
			char(30);

define ls_e_mail		char(384);
define _html_body		char(100);
define _mail_cc 		varchar(100);
define r_descripcion	char(30);
define _corredor		char(5);
define _cod_tipoprod	char(3);
define _cod_ramo		char(3);
define _cod_contratante char(10);
define _no_documento    char(20);
define v_tipo_envio		char(10);
define r_error_isam		smallint;
define _carta_bienv		smallint;
define r_error			smallint;
define _fronting	    smallint;
define _tipo_notif		smallint;
define _adj_file        smallint;
define _adjunto         smallint;
define _flag         smallint;
define _cnt             smallint;	
define _secuencia2		integer;
define _secuencia		integer;
define _cod_grupo		char(5);

define _cod_agente      char(5);
define _mail_cliente    varchar(200);
define _mail_agente     varchar(200);

begin

on exception set r_error, r_error_isam, r_descripcion
 	return r_error, r_descripcion;
end exception

set isolation to dirty read;

--set debug file to "sp_pro867.trc";
--trace on;

LET r_error       = 0;
LET _cnt          = 0;
LET _adjunto      = 0;
LET _flag	      = 0;
LET _adj_file     = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';
let _mail_cc = '';
--let _mail_agente = null;

select cod_contratante,
       no_documento,
	   cod_ramo,
	   fronting,
	   cod_tipoprod,
	   cod_grupo
  into _cod_contratante,
       _no_documento,
	   _cod_ramo,
	   _fronting,
	   _cod_tipoprod,
	   _cod_grupo
  from emipomae
 where no_poliza = a_no_poliza;

foreach
	select cod_agente
	  into _cod_agente
	  from emipoagt
	 where no_poliza = a_no_poliza

	if _cod_agente in ('00013','01847','01988','02351') then
		return 0,'';
	end if
end foreach

if _no_documento in('0922-00021-01','0922-00022-01') then
	return 0,''; --Caso 9889 Boni 27/03/2024
end if
 
if _cod_grupo in ('77793') then  -- EXCEPCIONAR ENVIO DE CARTA DE BIENVENIDA GRUPO: 77793 - GRUPO NACIONES UNIDAS
	return 0,''; --'El Grupo no aplica';   
end if

if _cod_tipoprod = '002' then
	return 0,'';
end if

if _fronting = 1 then
	return 0,'';
end if

if _cod_ramo = '008' then
	return 0,'';
end if

call sp_sis163(_cod_contratante) returning ls_e_mail;

if ls_e_mail is null or ls_e_mail = '' then
	return 0,'';
end if
if a_nueva_renov = 'N' then
	let v_tipo_envio = '00030';
	let _tipo_notif = 1;
else
	let _tipo_notif = 4;
	let v_tipo_envio = '00031';

	if _cod_ramo = '002' then
		let _adj_file = _adj_file + 1;  -- FACTURA SOLO AUTO
	elif _cod_ramo = '003' then  -- CASO: 27280 USER: ASTANZIO Ramo:003 tipo 00031 PRODUCTO 02662 2 Adj. Adicional
		select count(*)
		  into _cnt
		  from emipouni
		 where no_poliza = a_no_poliza
		   and cod_producto in ('02662')
		   and activo = 1;
		if _cnt > 1 then		-- Si encuentra una unidad se adjunta brochure y carta				
			let _adj_file =  2;
		end if
	end if	
end if

if _cod_grupo in ('1122','77850','77870','77857','77960') then  -- Añadir correos de Banisi para las pólizas del Colectivo Banisi Ducruet  
	let _mail_cc = 'seguros@banisipanama.com;pan.aff.trackingbanisi@willistowerswatson.com';
	let _flag = 1;
	let _adj_file = 1;
end if

let ls_e_mail = trim(ls_e_mail);

foreach	
	select first 1 e.cod_agente
	  into _corredor
	  from emipoagt e, agtagent a
	 where e.cod_agente = a.cod_agente
	   and e.no_poliza = a_no_poliza
	   and (a.carta_bienvenida = 1 or _flag = 1)

	let _adjunto = _adj_file;

	Select max(secuencia)
	  into _secuencia
	  from parmailsend;

	if _secuencia is null then
		let _secuencia = 0;
	end if

	let _secuencia = _secuencia + 1;
	let _html_body = "<html><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100>";

	insert into parmailsend(
			cod_tipo,
			email,
			enviado,
			adjunto,
			html_body,
			secuencia,
			sender)
	values(	v_tipo_envio,	--Carta de Bienvenida - poliza Nva. 
			ls_e_mail,
			0,
			_adjunto,    -- 1,CASO: 27280 USER: ASTANZIO Ramo:003 tipo 00031 PRODUCTO 02662 2 Adj. Adicional
			_html_body,
			_secuencia,
			_mail_cc);

	Select max(secuencia)
	  into _secuencia2
	  from parmailcomp;

	if _secuencia2 is null then
		let _secuencia2 = 0;
	end if

	let _secuencia2 = _secuencia2 + 1;

	insert into parmailcomp(
			secuencia,
			no_remesa,
			renglon,
			mail_secuencia,
			no_documento)
	values(	_secuencia2,
			a_no_poliza,
			0,
			_secuencia,
			_no_documento);
	call sp_sis458(_cod_contratante,_no_documento,_tipo_notif) returning r_error,r_descripcion;
	if r_error <> 0 then
		return r_error,r_descripcion;
	end if		
end foreach
return r_error, r_descripcion;
end
end procedure;