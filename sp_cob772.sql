-- Validacion de carga REMESA no tomar Polizas de BANISI - agente 02618
-- Realizado : Henry Giron 26/02/2019
 													   
drop procedure sp_cob772;

create procedure sp_cob772(a_cod_agente char(10), a_numero char(10), a_renglon integer)
returning integer,
          char(100);
define _cant	    integer;
define _error	    integer;
define _error_desc	char(100);

let _cant = 0;
let _error = 0;
let _error_desc =  "verificacion Ducruet Exitosa";

select count(*)
  into _cant
  from cobpaex0 a, cobpaex4 b
 where a.numero = b.numero
   and a.cod_agente = a_cod_agente   
   and b.cod_agente = '02618'  -- AGENTE BANISI DUCRUET en excepcion   
   and a.numero = a_numero   
   and a.insertado_remesa = 0
   and b.renglon = a_renglon;

    if _cant is null then
	   let _cant = 0;
   end if   

	if _cant <> 0 Then
	    let _error = 1;
	    let _error_desc = "Poliza pertenece a Banisi Ducruet " || a_numero|| " renglon " ||trim(cast(a_renglon as char(5)));    	
	end if

return _error, _error_desc;
end procedure