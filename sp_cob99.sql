-- Montos de Bancos por Remesa por Dia
-- 
-- Creado    : 17/03/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/03/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob99_dw1 - DEIVID, S.A.

drop procedure sp_cob99;

create procedure sp_cob99(a_compania CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7))
returning date,
          char(7),
		  char(10),
		  char(1),
		  dec(16,2),
		  char(3),
		  char(50),
		  char(50),
		  char(8),
		  date,
		  char(8),
		  date;

define v_no_remesa			char(10);
define v_tipo_remesa		char(1);
define v_cod_banco			char(3);
define v_fecha				date;
define v_monto				dec(16,2);
define v_periodo			char(7);
define v_compania_nombre	char(50); 
define v_banco_nombre		char(50); 
define v_date_added			date;
define v_date_posteo		date;
define v_user_added			char(8);
define v_user_posteo		char(8);

set isolation to dirty read;

let v_compania_nombre = sp_sis01(a_compania);

foreach
select no_remesa,
       tipo_remesa,
	   cod_banco,
	   fecha,
	   monto_chequeo,
	   periodo,
	   user_added,
	   date_added,
	   user_posteo,
	   date_posteo
  into v_no_remesa,
       v_tipo_remesa,
	   v_cod_banco,
	   v_fecha,
	   v_monto,
	   v_periodo,
	   v_user_added,
	   v_date_added,
	   v_user_posteo,
	   v_date_posteo
  from cobremae
 where periodo    >= a_periodo1 
   and periodo    <= a_periodo2
   and actualizado = 1
  
	if v_tipo_remesa = "A" or
	   v_tipo_remesa = "M" then
	   let v_tipo_remesa = "R";
	else
	   let v_tipo_remesa = "C";
	end if

	select nombre
	  into v_banco_nombre
	  from chqbanco
	 where cod_banco = v_cod_banco;

	return v_fecha,
	       v_periodo,
		   v_no_remesa,
		   v_tipo_remesa,
		   v_monto,
		   v_cod_banco,
		   v_banco_nombre,
		   v_compania_nombre,
		   v_user_added,
		   v_date_added,
	   	   v_user_posteo,
	   	   v_date_posteo
		   with resume;

end foreach

end procedure;