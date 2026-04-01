--Procedimiento para verificar el limite en los contratos de reaseguro y asi saber si tiene que ir a aprobacion en WF
--Armando Moreno M.  08/09/2017

drop procedure sp_sis453b;
create procedure sp_sis453b(a_no_poliza char(10), a_no_endoso char(10))
returning smallint, varchar(250);

define _cod_contrato,_no_unidad	char(5);
define _cod_cober_reas	char(3);
define _cantidad		smallint;

define _nomb_contrato	char(15);
define _cod_endomov, _cod_ramo     char(3);
define _nomb_cober		char(20);
define _tipo_contrato	smallint;
define _serie,_verif_lim			smallint;
define _prima,_prima_sus_uni  			dec(16,2);
define _mensaje varchar(250);
define _n_contrato   varchar(150);

let _prima          = 0.00;
let _prima_sus_uni  = 0.00;

select cod_endomov
  into _cod_endomov
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;
   
select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

if _cod_ramo not in('002','023') then
	return 0,"";
end if 

if _cod_endomov not in('004','005') then
	return 0,"";
end if

foreach
	select sum(prima),
		   no_unidad
	  into _prima,
		   _no_unidad
	  from emifacon
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	 group by no_unidad
	 order by no_unidad
	 
	select prima_suscrita
      into _prima_sus_uni
      from endeduni
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	   and no_unidad = _no_unidad;
	   
	if _prima <> _prima_sus_uni then
		let _mensaje = 'Debe Corregir Prima en Reaseguro para la unidad: ' || _no_unidad;
		return 1,_mensaje;
    end if	
  
end foreach
	
return 0,"";
end procedure
