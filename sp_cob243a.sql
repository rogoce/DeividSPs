--Procedimiento que alimenta la tabla historica del Proceso de TCR (cobtatrabk)

drop procedure sp_cob243a;
create procedure sp_cob243a(a_usuario char(8))
returning integer;

define _fecha_time datetime year to fraction(5);
define _null char(1);

let _null = null;
begin

	let _fecha_time = current;

	select * 
	  from cobtatra
	  into temp tmp_cobtat;

	insert into cobtatrabk(
			no_lote,
			renglon,
			no_tarjeta,
			codigo,
			prima_neta,
			impuesto,
			monto,
			fecha_exp,
			no_documento,
			nombre,
			saldo,
			procesar,
			motivo_rechazo,
			pronto_pago,
			procesado,
			date_procesado,
			user_proceso,
			date_added,
			user_added)
	select no_lote,
		   renglon,
		   no_tarjeta,
		   codigo,
		   prima_neta,
		   impuesto,
		   monto,
		   fecha_exp,
		   no_documento,
		   nombre,
		   saldo,
		   procesar,
		   motivo_rechazo,
		   pronto_pago,
		   0,
		   _null,
		   _null,
		   _fecha_time,
		   a_usuario
	  from tmp_cobtat;

	drop table tmp_cobtat;
end 
return 0;
end procedure;