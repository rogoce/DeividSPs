drop procedure sp_cob178;

create procedure sp_cob178()
returning char(20),
          dec(16,2),
		  dec(16,2);

define _no_documento 	char(20);
define _no_poliza		char(10);
define _cod_tipoprod	char(3);
DEFINE _saldo1             DEC(16,2);
DEFINE _saldo2             DEC(16,2);

DEFINE _prima_orig        DEC(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _por_vencer        DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _corriente         DEC(16,2);
DEFINE _monto_30          DEC(16,2);
DEFINE _monto_60          DEC(16,2);
DEFINE _monto_90          DEC(16,2);

define a_compania		  char(3);
define a_agencia		  char(3);
define _periodo			char(7);
define a_fecha			date;

set isolation to dirty read;

let a_compania = "001";
let a_agencia  = "001";
let _periodo   = "2004-12";
let a_fecha    = "31/12/2004";
	
{
create table tmp_compsaldo(
no_documento	char(20),
saldo1			dec(16,2),
saldo2			dec(16,2)
);
}

delete from tmp_compsaldo;

foreach
 select no_documento
   into _no_documento
   from emipomae
  where actualizado = 1
    and cod_ramo    = "002"
	and cod_tipoprod in ("001", "005")
  group by no_documento

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod
	  into _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
	   continue foreach;
	end if

	-- Prima Neta

	CALL sp_par78b(
		 a_compania,
		 a_agencia,
		 _no_documento,
		 _periodo,
		 a_fecha,
		 _no_poliza
		 ) RETURNING _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
					 _saldo,
					 _prima_orig;

	let _saldo1 = _monto_90;

	-- Prima Bruta

	CALL sp_cob33(
		 a_compania,
		 a_agencia,
		 _no_documento,
		 _periodo,
		 a_fecha
		 ) RETURNING _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
					 _saldo;          

	let _saldo2 = _monto_90;
	
	if _saldo1 = 0.00 and 
	   _saldo2 = 0.00 then
	   continue foreach;
	end if

	insert into tmp_compsaldo
	values (_no_documento, _saldo1, _saldo2);
	  

end foreach

foreach
 select no_documento, 
 		saldo1, 
 		saldo2
   into _no_documento, 
 		_saldo1, 
 		_saldo2
   from tmp_compsaldo

	if _saldo1 > _saldo2 then

		return _no_documento, 
	 		   _saldo1, 
	 		   _saldo2
			   with resume;

	end if

end foreach

end procedure