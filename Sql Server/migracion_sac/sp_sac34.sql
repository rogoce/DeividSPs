-- Verificacion entre SAC y Archivo Excel de Ana
--
-- Creado    : 29/03/2005 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac34;

create procedure "informix".sp_sac34()
returning char(25),
          char(25),
		  dec(16,2),
		  dec(16,2),
		  char(1),
		  char(3);

define _campo1		char(3);
define _campo2		char(2);
define _campo3		char(2);
define _campo4		char(2);
define _campo5		char(2);
define _campo6		char(2);
define _campo7		dec(16,2);
define _campo8		dec(16,2);
define _campo9		dec(16,2);

define _cuenta		char(25);
define _cuenta_ana	char(25);

define _tipo		char(2);
define _ccosto		char(3);
define _ano			char(4);
define _periodo     smallint;
define _saldo_ant	dec(16,2);
define _saldo_act	dec(16,2);

define _cta_recibe	char(1);
define _cuenta3     char(3);

set isolation to dirty read;

let _tipo   	= "01";
let _ccosto 	= "001";
let _ano    	= "2005";
let _periodo	= 1;

foreach
 select	campo1,
		campo2,
		campo3,
		campo4,
		campo5,
		campo6,
		campo7,
		campo8
   into	_campo1,
		_campo2,
		_campo3,
		_campo4,
		_campo5,
		_campo6,
		_campo7,
		_campo8
   from	ana2005

	let _cuenta_ana = _campo1 || " " || _campo2 ||  " " || _campo3 ||  " " || _campo4 ||  " " || _campo5 ||  " " || _campo6;
	

	if _campo6 <> "00" then

		let _cuenta = _campo1 || _campo2 || _campo3 || _campo4 || _campo5 || _campo6;

	elif _campo5 <> "00" then

		let _cuenta = _campo1 || _campo2 || _campo3 || _campo4 || _campo5;

	elif _campo4 <> "00" then

		let _cuenta = _campo1 || _campo2 || _campo3 || _campo4;

	elif _campo3 <> "00" then

		let _cuenta = _campo1 || _campo2 || _campo3;

	elif _campo2 <> "00" then

		let _cuenta = _campo1 || _campo2;

	elif _campo1 <> "00" then

		let _cuenta = _campo1;

	else

		let _cuenta = "";

	end if

	if _cuenta = "" then
		continue foreach;
	end if

	let _cuenta = sp_sac35(_cuenta);

	select cta_recibe
	  into _cta_recibe
	  from cglcuentas
	 where cta_cuenta = _cuenta;
	 
	if _cta_recibe is null then
		let _cta_recibe = "S";
	end if
	
	if _cta_recibe = "N" then 
		continue foreach;
	end if

	if _cta_recibe = "S" then 

		select sldet_debtop
		  into _saldo_ant
		  from cglsaldodet2
	     where sldet_tipo    = _tipo
	       and sldet_cuenta  = _cuenta
		   and sldet_ccosto  = _ccosto
		   and sldet_ano     = _ano
	       and sldet_periodo = _periodo;

	else

		select sum(sldet_debtop)
		  into _saldo_ant
		  from cglsaldodet2
	     where sldet_tipo    = _tipo
	       and sldet_cuenta  like trim(_cuenta) || "%"
		   and sldet_ccosto  = _ccosto
		   and sldet_ano     = _ano
	       and sldet_periodo = _periodo;

	end if

	if _saldo_ant is null then
		let _saldo_ant = 0.00;
	end if

	if _campo7 is null then
		let _campo7 = 0.00;
	end if
	
	if _campo8 is null then
		let _campo8 = 0.00;
	end if

	let	_campo9 = _campo7 + _campo8;

	if _campo9 is null then
		let _campo9 = 0.00;
	end if

	if _saldo_ant = _campo9 then
		continue foreach;
	end if

	let _cuenta3 = _cuenta[1,3];

	return _cuenta_ana,
	       _cuenta,
		   _campo9,
		   _saldo_ant,
		   _cta_recibe,
		   _cuenta3
		   with resume;

end foreach

end procedure