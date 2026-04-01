-- Procedimiento que retorna el documento de prima en suspenso que se genero para la poliza

-- Creado    : 28/10/2011 - Autor: Demetrio Hurtado Almanza


drop procedure sp_cob296;

create procedure sp_cob296(a_no_documento char(30))
returning char (20);

define _doc_suspenso char(30);

let _doc_suspenso = null;

foreach
 select doc_suspenso
   into _doc_suspenso
   from cobsuspe
  where ramo   = a_no_documento 
     or poliza = a_no_documento
  order by fecha
	exit foreach;
end foreach

return _doc_suspenso;

end procedure
