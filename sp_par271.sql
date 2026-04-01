-- Procedure que genere el registro contable de las Bonificaciones de cobranza

-- Creado    : 15/03/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_che06 - DEIVID, S.A.

drop procedure sp_par271;

create procedure "informix".sp_par271(
a_cod_agente	char(5),
a_periodo		char(7),
a_no_requis 	char(10)
) returning integer,
            char(50);

define _cod_ramo			char(3);
define _cod_subramo			char(3);
define _cod_origen			char(3);
define _renglon				smallint;
define _renglon2			smallint;
define _monto				dec(16,2);
define _cuenta				char(25);
define _cnt                 integer;

define _monto_cheque		dec(16,2);

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Bonificaciones

delete from chqctaux where no_requis = a_no_requis;
delete from chqchcta where no_requis = a_no_requis;
   
let _renglon = 0;

select monto
  into _monto_cheque
  from chqchmae
 where no_requis = a_no_requis;

foreach
 select cod_origen,
        cod_ramo,
		cod_subramo,
	 	sum(comision)
   into _cod_origen,
   		_cod_ramo,
		_cod_subramo,
		_monto
   from chqboni
  where cod_agente = a_cod_agente
    and periodo    = a_periodo
  group by cod_origen, cod_ramo, cod_subramo
  order by cod_origen, cod_ramo, cod_subramo

	-- Registros Contables de Honorarios por Pagar

	LET _cuenta  = sp_sis15('PPGHONXPCO', "04", _cod_origen, _cod_ramo, _cod_subramo);

	let _cuenta = trim(_cuenta);

	select count(*)
	  into _cnt
	  from chqchcta
	 where no_requis    = a_no_requis
	   and trim(cuenta) = _cuenta;

	if _cnt = 0 then

		let _renglon = _renglon + 1 ;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_monto,
		0
		);
	else
		foreach

			select renglon
			  into _renglon2
			  from chqchcta
			 where no_requis = a_no_requis
			   and cuenta    = _cuenta

			exit foreach;

		end foreach

		update chqchcta
		   set debito = debito + _monto
		 where no_requis = a_no_requis
		   and renglon   = _renglon2;
	end if

end foreach

end

select sum(debito)
  into _monto
  from chqchcta
 where no_requis = a_no_requis;

if _monto <> _monto_cheque then

	return 1, "Error en los Registros Contables";

else

	return 0, "Actualizacion Exitosa";

end if

end procedure