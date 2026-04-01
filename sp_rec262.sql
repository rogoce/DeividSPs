-- Procedure que retorna la lista de correos en cadena

-- AmadoPerez 27/07/2011


drop procedure sp_rec262;

create procedure sp_rec262(a_reclamo char(10), a_cobertura char(5))
RETURNING dec(16,2);

define _limite      	dec(16,2);
define _limite_1      	dec(16,2);
define _limite_2      	dec(16,2);
define _cant            smallint;
define _no_poliza       char(10);
define _no_unidad       char(5);
define _no_endoso       char(5);
define _fecha_siniestro date;

set isolation to dirty read;

let _limite = 0;

select no_poliza,
       no_unidad,
	   fecha_siniestro
  into _no_poliza,
       _no_unidad,
	   _fecha_siniestro
  from recrcmae
 where no_reclamo = a_reclamo;

select count(*)
  into _cant
  from emipocob
 where no_poliza = _no_poliza
   and no_unidad = _no_unidad
   and cod_cobertura  = a_cobertura;
   
if _cant > 0 then
	select limite_1,
	       limite_2
	  into _limite_1,
	       _limite_2
      from emipocob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura  = a_cobertura;
else
	let _no_endoso = sp_rec341(_no_poliza, _no_unidad, _fecha_siniestro);
	select limite_1,
	       limite_2
	  into _limite_1,
	       _limite_2
      from endedcob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and no_endoso = _no_endoso
	   and cod_cobertura  = a_cobertura;
end if	
--return 1000000;	
If _limite_2 is null or _limite_2 = 0 then				  
	RETURN _limite_1;
Else
	RETURN _limite_2;
End If
end procedure