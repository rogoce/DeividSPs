-- Informaci¢n: para Panam  Presentar los datos en el Grid
-- Creado     : 11/09/2007 - Autor: Rub‚n Dar¡o Arn ez S nchez
-- Modificado : 22/10/2007 - Por  : Rub‚n Dar¡o Arn ez S nchez para incluir el nombre del perfil de cada ususario

--DROP PROCEDURE sp_sis120;

create procedure "informix".sp_sis120()
returning CHAR(1);


DEFINE _sldet_tipo	  char(2);
DEFINE _sldet_cuenta  char(12);
DEFINE _sldet_ccosto  char(3);
DEFINE _sldet_ano	  char(4);
DEFINE _sldet_periodo smallint;
DEFINE _renglon       integer;

SET ISOLATION TO DIRTY READ;


let _renglon = 1;

foreach 

	 select sldet_tipo,
			sldet_cuenta,
			sldet_ccosto,
			sldet_ano,
			sldet_periodo
	   into _sldet_tipo,
	        _sldet_cuenta,
		    _sldet_ccosto,
		    _sldet_ano,
		    _sldet_periodo
	   from saldodet
	  order by sldet_tipo, sldet_cuenta, sldet_ccosto, sldet_ano, sldet_periodo

	  update saldodet
	     set renglon = _renglon
	   where sldet_tipo	   = _sldet_tipo
		 and sldet_cuenta  = _sldet_cuenta
		 and sldet_ccosto  = _sldet_ccosto
		 and sldet_ano	   = _sldet_ano
		 and sldet_periodo = _sldet_periodo;

     let _renglon = _renglon + 1;
		   
end foreach;

return '0';

end procedure;
