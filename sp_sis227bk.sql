DROP PROCEDURE sp_sis227bk;

CREATE PROCEDURE sp_sis227bk(a_requis char(10))
RETURNING char(7),char(7),dec(16,2);

define _origen_cheque char(1); 
define _monto,_monto_c   dec(16,2);
define _tipo_requis   char(1);
define _en_firma      smallint;
define _numrecla      char(20);
define _periodo_requis char(7);
define _anio,_mes     integer;
define _periodo_act char(7);
define _mes_char    char(2);

set isolation to dirty read;

select origen_cheque, 
       monto,
	   tipo_requis,
	   en_firma,
	   periodo
  into _origen_cheque, 
       _monto,
	   _tipo_requis,
	   _en_firma,
	   _periodo_requis
  from chqchmae
 where no_requis = a_requis;
 
let _monto_c = 0.00;
let _monto_c = _monto;

  if _origen_cheque = '3' and _en_firma = 2 then
	foreach
		select numrecla
		  into _numrecla
		  from chqchrec
		 where no_requis = a_requis
	 exit foreach;
	end foreach
	
	if _numrecla[1,2] in ('02','20','23') then
		
	elif _numrecla[1,2] in ('04','16','18','19') then
	
	select anio,
           mes
      into _anio,
	       _mes
	  from cheprereq
	 where anio = year(today)
	   and mes = month(today)
	   and opc = 2;
	
	if _mes > 9 then
		let _periodo_act = _anio || '-' || _mes;
	else
		let _mes_char = '0' || _mes;
		let _periodo_act = _anio || '-' || _mes_char;
	end if
	if _periodo_requis < _periodo_act then
		let _monto_c = 110;
	end if
		
	end if	
  
  end if

return _periodo_act,_periodo_requis,_monto_c;

end procedure