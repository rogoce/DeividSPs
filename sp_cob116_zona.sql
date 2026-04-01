-- Procedimiento para traer Corredor, Zona de Cobros y Division de Cobros.
--
-- Creado    : 15/03/2011 - Autor: Demetrio Hurtado Almanza
-- Modificado: 09/11/2011 - Autor: Roman Gordon					**Insercion de la Division de Cobros.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob116;

create procedure "informix".sp_cob116(a_poliza char(10))
	   returning char(5),
	             char(100),
	             char(3),
	             char(50),
	             smallint,
	             char(1),
	             char(50);

define _cod_formapag	char(3);
define _nombre_formapag	char(50);
define v_cod_agente  	char(5); 
define v_agente      	char(100);
define v_cod_cobrador 	char(3);
define v_cobrador    	char(50);
define _nombre_agente	char(100);
define v_leasing        smallint;
define _cod_div_cob		char(1);
define _nom_div_cob		char(50);


--set debug file to "sp_cob116.trc"; 
--trace on;
   	
set isolation to dirty read;
   
select leasing,
	   cod_formapag
  into v_leasing,
	   _cod_formapag
  from emipomae
 where no_poliza = a_poliza;

-- Agente

let _nombre_agente = "";

foreach
 select cod_agente		 
   into v_cod_agente
   from emipoagt
  where no_poliza = a_poliza

	select nombre
      into v_agente
	  from agtagent
	 where cod_agente = v_cod_agente;

	let _nombre_agente = trim(_nombre_agente) || trim(v_agente) || " \ ";
	   
end foreach

let v_agente = _nombre_agente;

-- Zona de Cobros
select nombre,
       cod_cobrador
  into _nombre_formapag,
       v_cod_cobrador
  from cobforpa
 where cod_formapag = _cod_formapag;

if v_cod_cobrador is null then

	select cod_cobrador
	  into v_cod_cobrador
	  from agtagent
	 where cod_agente = v_cod_agente;

end if

select nombre 
  into v_cobrador
  from cobcobra
 where cod_cobrador = v_cod_cobrador;

select cobra_poliza
  into _cod_div_cob
  from cobdivco
 where cod_formapag = _cod_formapag
   and cod_cobrador = v_cod_cobrador;

select nombre
  into _nom_div_cob
  from cobdivis
 where cod_division = _cod_div_cob;


return v_cod_agente,  
	   v_agente,      
	   _cod_formapag,
	   _nombre_formapag,
	   v_leasing,
	   _cod_div_cob,
	   _nom_div_cob;    

end procedure
