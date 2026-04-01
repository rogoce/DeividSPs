-- Promotores en Conflicto

-- Creado    : 1O/07/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par229;

create procedure "informix".sp_par229()
returning char(5),
          char(50),
		  char(3),
		  char(50),
		  char(3),
		  char(50),
		  char(3);

define _cod_agente		char(5);
define _cod_agencia		char(3);
define _cod_ramo		char(3);
define _cod_vendedor	char(3);
define _cod_tiporamo	char(3);

define _cod_vend_pe		char(3);
define _cod_vend_cm		char(3);

define _nombre_agente	char(50);
define _nombre_vend_pe	char(50);
define _nombre_vend_cm	char(50);

define _cod_ramo2		char(3);

define _cod_vend_eva	char(3);
define _cod_tipo_eva	char(3);

create temp table tmp_promotor(
cod_agente		char(5),
cod_ramo		char(3),
cod_vend_pe		char(3),
cod_vend_cm		char(3),
primary key (cod_agente, cod_ramo)
) with no log;

foreach
 select p.cod_agente,
		r.cod_tiporamo
   into _cod_agente,
        _cod_ramo
   from	parpromo p, prdramo r
  where p.cod_agencia  in ("001", "004")
    and r.cod_tiporamo in ("001", "002")
    and p.cod_ramo     =  r.cod_ramo
  group by 1, 2
  order by 1, 2
  
  insert into tmp_promotor
  values (_cod_agente, _cod_ramo, "", "");  
	
end foreach

foreach
 select cod_agente,
		cod_agencia,
        cod_ramo,
        cod_vendedor
   into _cod_agente,
        _cod_agencia,
        _cod_ramo,
        _cod_vendedor
   from	parpromo
  where cod_agencia in ("001", "004")

	select cod_tiporamo
	  into _cod_tiporamo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _cod_tiporamo = "003" then
		continue foreach;
	end if

	if _cod_agencia = "001" then
		
		update tmp_promotor
		   set cod_vend_cm = _cod_vendedor
		 where cod_agente  = _cod_agente
		   and cod_ramo    = _cod_tiporamo;

	else

		update tmp_promotor
		   set cod_vend_pe = _cod_vendedor
		 where cod_agente  = _cod_agente
		   and cod_ramo    = _cod_tiporamo;

	end if

end foreach

let _cod_vend_eva = "027";
let _cod_tipo_eva = "001";

foreach
 select cod_agente,
        cod_ramo,
        cod_vend_cm,
        cod_vend_pe
   into _cod_agente,
        _cod_tiporamo,
        _cod_vend_cm,
        _cod_vend_pe
   from tmp_promotor
  where cod_vend_cm <> cod_vend_pe 
                
	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente; 	

	select nombre
	  into _nombre_vend_cm
	  from agtvende
	 where cod_vendedor = _cod_vend_cm; 	

	select nombre
	  into _nombre_vend_pe
	  from agtvende
	 where cod_vendedor = _cod_vend_pe; 	

	--{
	foreach
	 select cod_ramo
	   into _cod_ramo2
	   from prdramo
	  where cod_tiporamo = _cod_tiporamo

	    update parpromo
		   set cod_vendedor = _cod_vend_cm
		 where cod_agente   = _cod_agente
		   and cod_ramo   	= _cod_ramo2
		   and cod_agencia	= "004";

	end foreach
	--}			

	return _cod_agente,
	       _nombre_agente, 
		   _cod_vend_cm,
	       _nombre_vend_cm,
		   _cod_vend_pe,
	       _nombre_vend_pe,
		   _cod_tiporamo
		   with resume;


end foreach

drop table tmp_promotor;

return "0",
       "", 
	   "",
       "",
	   "",
       "",
	   ""
	   with resume;

end procedure