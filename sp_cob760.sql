-- Procedimiento que actualiza Zonas de Cobros en AgtAgent
-- Creado :	11/02/2011 - Autor: Henry Giron	Solicitud: Demetrio
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob760;		

create procedure "informix".sp_cob760()
returning integer, char(3), char(5), char(100);

define _zona			char(3);
define _agente			char(5);
define _cobrador 		char(3);
define _existe          smallint;
define _cantidad		integer;

set isolation to dirty read;


create temp table tmp_duplikdo(
zona	char(3),
agente	char(5)
) with no log;

let _cantidad = 0;

update agtagent
   set cod_cobrador = "186";

foreach
 select zona,agente
   into _zona,_agente
   from deivid_tmp:tmp_zonas_cobros
  order by zona,agente

       let _existe = 0;

    select count(*)
	  into _existe
	  from agtagent
	 where cod_agente = _agente;

	    if _existe is null then
		   let _existe = 0;
	   end if

		if _existe = 0 then
		   return 1,_zona,_agente,"No existe."
		   with resume;
	   end if

       let _existe = 0;

    select count(*)
	  into _existe
	  from tmp_duplikdo
	 where agente = _agente;

	    if _existe is null then
		   let _existe = 0;
	   end if

		if _existe <> 0 then
		   return 1,_zona,_agente,"Duplicado."
		   with resume;
	  else
			update agtagent
			   set cod_cobrador = _zona
			 where cod_agente = _agente;

		       let _cantidad = _cantidad + 1;

			insert into tmp_duplikdo
			values (_zona, _agente);

	   end if

end foreach

return 0, "", "", "Actualizacion Exitosa "||_cantidad ;
drop table tmp_duplikdo;

end procedure
				  