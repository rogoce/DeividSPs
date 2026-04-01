--Armando Moreno 26/06/2013
--Procedure para notificar si la renovacion que quieren hacer es de mas de tres meses con respecto al periodo actual.


drop procedure sp_sis69a;

create procedure "informix".sp_sis69a(a_periodo_act char(7), a_periodo_ren char(7))
returning smallint,char(100);


DEFINE _valor              integer;
DEFINE _valor2             integer;
DEFINE _valor1             integer;

set isolation to dirty read;

let _valor1 = a_periodo_act[6,7];

let _valor1 = _valor1 + 3;

if _valor1 < 10 then

  let a_periodo_act[6,7] = '0' || _valor1;

else
  if _valor1 > 12 then

	  let a_periodo_act[1,4] = a_periodo_act[1,4] + 1;
	  let _valor2 = _valor1 - 12;
	  if _valor2 < 10 then
		  let a_periodo_act[6,7] = '0' || _valor2;
	  else
		  let a_periodo_act[6,7] = _valor2;
	  end if
  else
		  let a_periodo_act[6,7] = _valor1;
  end if
	  
end if

let a_periodo_ren[1,4] = a_periodo_ren[1,4] + 1;


if a_periodo_ren > a_periodo_act then

	return 1,'VA A RENOVAR CON MAS DE TRES MESES, DESEA CONTINUAR?';
else
	return 0,'SI PUEDE RENOVAR.';
end if

end procedure
