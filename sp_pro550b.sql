-- Procedimiento que determina las variables para el descuento por siniestralidad


drop procedure sp_pro550b;
create procedure sp_pro550b(a_no_documento char(20))
returning char(20),	char(18),char(10),date,varchar(24),char(9),varchar(50),char(2),dec(16,2); 

define _no_poliza,_no_tramite	char(10);
define _no_reclamo			char(10);
define _fecha_siniestro	date;
define _cod_evento          char(3);
define _incurrido_bruto	   dec(16,2);
define _incurrido			dec(16,2);
define _est_recl           char(9);
define _est_aud            varchar(25);
define _perd_total         char(2);
define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _numrecla            char(18);
define _n_evento            varchar(50);

--set debug file to "sp_pro550b.trc";
--trace on;

-- Numero de Siniestros Ultima Vigencia
let _no_poliza = sp_sis211(a_no_documento);
let _incurrido = 0.00;
foreach
	select numrecla,
	       no_reclamo,
		   no_tramite,
		   fecha_siniestro,
		   decode(estatus_audiencia,1,"Ganado",0,"Perdido",2,"Por Definir",3,"Proceso Penal",4,"Proceso Civil",5,"Apelación",6,"Resuelto",7,"FUD - Ganado",
		          8,"FUD - Responsable",9,"Pend. de Audiencia",10,"Pend. de Resolución",11,"Ganado-Pend. Resolución",12,"Perdido-Pend. Resolución"),
		   decode(estatus_reclamo,"A","Abierto","C","Cerrado","D","Declinado","N","No Aplica"),
		   cod_evento,
		   decode(perd_total,1,"SI",0,"NO")
	  into _numrecla,
	       _no_reclamo,
		   _no_tramite,
		   _fecha_siniestro,
		   _est_aud,
		   _est_recl,
		   _cod_evento,
		   _perd_total
	  from recrcmae
	 where no_poliza  =  _no_poliza
      and actualizado = 1
	  
	select nombre
	  into _n_evento
	  from recevent
	 where cod_evento = _cod_evento; 

	let _incurrido = sp_rec255(_no_reclamo);
			
	return a_no_documento,_numrecla,_no_tramite,_fecha_siniestro,_est_aud,_est_recl,_n_evento,_perd_total,_incurrido with resume;
	
end foreach
end procedure

