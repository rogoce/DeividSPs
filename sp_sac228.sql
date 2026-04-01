-- Procedimiento que carga los movimientos de las cuentas de contabilidad
-- Creado    : 03/07/2013 - Autor: Federico Coronado

-- drop procedure sp_sac228;

create procedure "informix".sp_sac228(
a_no_cuenta		varchar(25), 
a_nombre 		varchar(50),
a_origen 		varchar(50),
a_transaccion	varchar(10),
a_monto 		dec(16,2),
a_fecha 		date,
a_user_added 	char(8)
)returning integer, 
          char(50);

define v_secuencia		integer;
define v_parmailsend    integer;
define v_tipo_mov       char(5);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _secuencia		integer;
define _html_body		char(512);


begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_sac228.trc"; 
--trace on;

let v_tipo_mov = '00028';
	  
	select count(*)
	  into v_parmailsend
	  from deivid:movaud
	 where enviado = 0;
	   
	if v_parmailsend = 0 then
		let _secuencia = sp_sis148();
		let _html_body = "<html><table><tr><td>Buenos d&iacute;as,</td></tr><tr><td>Adjunto encontrara  el reporte con los movimientos de las cuentas que tienen registros auxiliares en Deivid </td></tr><tr><td><img src=cid:" ||  _secuencia || ".jpg width=850 height=1100  /></td></tr></table>";

		insert into deivid:parmailsend(
		cod_tipo,
		email,
		enviado,
		adjunto,
		secuencia,
		html_body,
		sender
		)
		values(
		v_tipo_mov,
		'lmoreno@asegurancon.com',
		0,
		1,
		 _secuencia, 
		_html_body,
		null 
		);
	end if
	insert into deivid:movaud(
		   tipo_mov,
		   cuenta, 
		   nombre, 
		   origen, 
		   transaccion, 
		   monto, 
		   enviado,
		   fecha,
		   user_added)	
		   VALUES(
			v_tipo_mov,
			a_no_cuenta,
			a_nombre,
			a_origen,
			a_transaccion,
			a_monto,
			0,
			a_fecha,
			a_user_added);
		return 0, "Actualizacion Exitosa";
	end
end procedure 