-- procedimiento dias valido para cancelar
-- creado    : 08/11/2019 - autor: Roman Gordon
-- sis v.2.0 - deivid, s.a.
-- execute procedure sp_sis461('01/07/2011',2)

drop procedure sp_sis461;
create procedure sp_sis461()
returning	varchar(100)	as email,
			smallint		as enviado,
			date			as date_added,
			date			as fecha_envio,
			char(5)			as no_aviso,
			smallint		as renglon,
			char(20)		as no_documento,
			varchar(50)		as nombre_ramo,
			varchar(50)		as nombre_cliente,
			dec(16,2)		as exigible,
			varchar(50)		as nombre_formapag,
			char(1)			as estatus,
			char(8)			as user_proceso,
			date			as fecha_proceso,
			date			as fecha_marcar,
			char(8)			as user_marcar,
			char(8)			as usuario1,
			varchar(50)		as cargo1,
			char(8)			as usuario2,
			varchar(50)		as cargo2,
			date			as fecha_cancelacion;

define _nombre_formapag	varchar(50);
define _nombre_cliente	varchar(50);
define _nombre_ramo		varchar(50);
define _cargo1			varchar(50);
define _cargo2			varchar(50);
define _email			varchar(100);
define _no_documento	char(20);
define _user_proceso	char(8);
define _user_marcar		char(8);
define _usuario1		char(8);
define _usuario2		char(8);
define _no_aviso		char(5);
define _estatus			char(1);
define _exigible		dec(16,2);
define _fecha_proceso	date;
define _fecha_quitar	date;
define _fecha_marcar	date;
define _date_added		date;
define _fecha_envio		date;
define _enviado			smallint;
define _renglon			smallint;

foreach
SELECT env.email,
	   env.enviado,
	   env.date_added,
	   env.fecha_envio,
	   can.no_aviso,
	   can.renglon,
	   can.no_documento,
	   can.nombre_ramo,
	   can.nombre_cliente,
	   can.exigible,
	   can.nombre_formapag,
	   can.estatus,
	   can.user_proceso,
	   can.fecha_proceso,
	   can.fecha_marcar,
	   can.user_marcar,
	   can.usuario1,
	   can.cargo1,
	   can.usuario2,
	   can.cargo2
  INTO _email,
	   _enviado,
	   _date_added,
	   _fecha_envio,
	   _no_aviso,
	   _renglon,
	   _no_documento,
	   _nombre_ramo,
	   _nombre_cliente,
	   _exigible,
	   _nombre_formapag,
	   _estatus,
	   _user_proceso,
	   _fecha_proceso,
	   _fecha_marcar,
	   _user_marcar,
	   _usuario1,
	   _cargo1,
	   _usuario2,
	   _cargo2	   
FROM parmailsend env
 INNER JOIN parmailcomp com
		 ON env.secuencia = com.mail_secuencia
		AND cod_tipo = '00010'
		AND date_added >= DATE('06/12/2023')
		AND env.enviado = 3
 INNER JOIN avisocanc can
		 ON can.no_aviso = com.no_remesa
		AND can.renglon = com.renglon
		AND can.estatus NOT IN ('Z','Y','X')
		AND can.fecha_marcar IS NULL
   and can.no_aviso = '02584'    --- and can.no_documento in ('0222-01925-01','0222-02249-01','0223-06711-09','0223-07362-09')
  -- and can.nombre_cliente = 'ROLANDO ALBERTO RODRIGUEZ ESPINOSA'

call sp_sis388a(_fecha_envio,15) returning _fecha_quitar;

update avisocanc
   set user_marcar = 'DEIVID',
	   fecha_marcar = _fecha_quitar,
	   estatus = 'M'
 where no_aviso = _no_aviso
   and renglon = _renglon;

return _email,
	   _enviado,
	   _date_added,
	   _fecha_envio,
	   _no_aviso,
	   _renglon,
	   _no_documento,
	   _nombre_ramo,
	   _nombre_cliente,
	   _exigible,
	   _nombre_formapag,
	   _estatus,
	   _user_proceso,
	   _fecha_proceso,
	   _fecha_marcar,
	   _user_marcar,
	   _usuario1,
	   _cargo1,
	   _usuario2,
	   _cargo2,
	   _fecha_quitar with resume;
end foreach
end procedure;