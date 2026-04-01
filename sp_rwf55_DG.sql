-- Reporte para las requisiciones de Reclamos de Salud	en firma

-- Creado    : 12/07/2006 - Autor: Armando Moreno

drop procedure sp_rwf55;

create procedure sp_rwf55()
 returning char(10),
		   char(100),
		   dec(16,2),
		   char(8),
		   char(8),
		   date,
		   char(8),
		   smallint,
		   char(30),
		   char(3),
		   char(3);

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _user_added      char(8);
define _fecha_captura   date;
define _cant_firmas     smallint;
define _e_mail          char(30);

SET ISOLATION TO DIRTY READ;
foreach
	select cod_banco,
	       cod_chequera
	  into _cod_banco,
		   _cod_chequera
	  from chqbanch
	 where cod_ramo <> '*'
	 group by cod_banco, cod_chequera

	foreach
	 select	no_requis,
			cod_cliente,
			monto,
			a_nombre_de,
			firma1,
			firma2,
			fecha_captura,
			user_added
	   into	_no_requis,
			_cod_cliente,
			_monto,
			_a_nombre_de,
			_firma1,
			_firma2,
			_fecha_captura,
			_user_added
	   from	chqchmae
	  where anulado       = 0
		and cod_banco     = _cod_banco
		and cod_chequera  = _cod_chequera
		and pagado        = 0
		and en_firma      = 1
		and monto > 0.00
		and no_requis not in ('889137','889062')

	 select e_mail
	   into _e_mail
	   from insuser
	  Where usuario = _user_added;
	 
	  If _firma2 Is null Or trim(_firma2) = "" Then
		 Let _cant_firmas = 1;
	  Else
		 Let _cant_firmas = 2;
	  End If

		return _no_requis,
			   _a_nombre_de,
			   _monto,
			   _firma1,
			   _firma2,
			   _fecha_captura,
			   _user_added,
			   _cant_firmas,
			   _e_mail,
			   _cod_banco,   
			   _cod_chequera
			   with resume;

	end foreach
end foreach
end procedure
