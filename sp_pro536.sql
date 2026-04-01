-- Creacion de las letras de pago de las polizas por nueva ley de seguros

-- Creado    : 21/06/2012 - Autor: Demetrio Hurtado Almanza
-- modificado: 05/12/2013 - Autor: Angel Tello
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro536;

create procedure sp_pro536(
a_no_poliza	char(10)
) returning	smallint,
			date,
			dec(16,2),
			date,
			date,
			smallint,
			date,
			dec(16,2),
			date,
			date,
			dec(16,2);

define _letra			smallint;
define _periodo_gracia	date;
define _monto_letra		dec(16,2);
define _vigencia_inic	date;
define _vigencia_final	date;
define _letra2			smallint;
define _periodo_gracia2	date;
define _monto_letra2	dec(16,2);
define _cnt				smallint;
define _fila          	smallint;
define _vigencia_ini2	date;
define _vigencia_fina2	date;
define _monto_total		dec(16,2);

create temp table tmp_letra(
       fila            smallint,
       letra1          smallint,
	   periodo_gracia1 date,
	   vigencia_ini1   date,
	   vigencia_fina1  date,
	   monto_letra1    dec(16,2),
       letra2          smallint,
	   periodo_gracia2 date,
	   monto_letra2    dec(16,2),
	   vigencia_ini2   date,
	   vigencia_fina2  date,
	   monto_total	   dec(16,2),
	   PRIMARY KEY (fila)
	   ) WITH NO LOG;

set isolation to dirty read;

let _cnt = 1;
let _fila = 1;

select prima_bruta
	into _monto_total
	from emipomae
where no_poliza = a_no_poliza;



foreach
	select no_letra,
		   periodo_gracia,
		   monto_letra,
		   vigencia_inic,
		   vigencia_final
	  into _letra,
		   _periodo_gracia,
		   _monto_letra,
		   _vigencia_inic,
		   _vigencia_final
	  from emiletra
	 where no_poliza = a_no_poliza

	 if _cnt < 7 then
	    insert into tmp_letra(
		   fila,
		   letra1,
		   periodo_gracia1,
		   monto_letra1,
		   vigencia_ini1,
		   vigencia_fina1,
		   monto_total)
		 values (
		   _fila,
		   _letra,
		   _periodo_gracia,
		   _monto_letra,
		   _vigencia_inic,
		   _vigencia_final,
		   _monto_total);

	  	let _fila = _fila + 1;
	  else
	  	let _fila = _cnt - 6;

	     update tmp_letra
		    set letra2          =  _letra,
				periodo_gracia2	=  _periodo_gracia,
				monto_letra2   	=  _monto_letra,
				vigencia_ini2   =  _vigencia_inic,
				vigencia_fina2  =  _vigencia_final


		  where fila = _fila;

      end if

      let _cnt = _cnt + 1;

end foreach

foreach	with hold
	 select letra1,
	 		periodo_gracia1,
	 		monto_letra1,
			vigencia_ini1,
			vigencia_fina1,
	 		letra2,
			periodo_gracia2,
			monto_letra2,
			vigencia_ini2,
			vigencia_fina2,
			monto_total
	   into _letra,
	   		_periodo_gracia,
	   		_monto_letra,
			_vigencia_inic,
			_vigencia_final,
	   		_letra2,
	   		_periodo_gracia2,
	   		_monto_letra2,
			_vigencia_ini2,
			_vigencia_fina2,
			_monto_total
	   from tmp_letra
	  order by fila

     return _letra,
			_periodo_gracia,
			_monto_letra,
			_vigencia_inic,
			_vigencia_final,
			_letra2,
			_periodo_gracia2,
			_monto_letra2,
			_vigencia_ini2,
			_vigencia_fina2,
			_monto_total
				with resume;
end foreach

DROP TABLE tmp_letra;

end procedure
