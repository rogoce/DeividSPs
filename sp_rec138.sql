-- Control de Asignaciones. Reclamos de vida y Salud.  en mora
-- Creado    : 28/12/2009 - Autor: Armando Moreno.
drop procedure sp_rec138;
create procedure "informix".sp_rec138()
returning	integer,
			char(10),
			char(20),
			char(10),
			char(10),
			char(10),
			char(100),
			char(100),
			dec(16,2),
			char(10),
			char(10),
			smallint,
			char(50),
			datetime year to fraction(5),
			varchar(255),
			char(3),
			char(50),
			char(50),
			dec(16,2),
			varchar(50);

define _obs_mora         varchar(255);
define _nom_formapag     varchar(50);
define _nom_corredor     varchar(50);
define _reclamante	     char(100);
define _asegurado	     char(100);
define _nom_cobrador	 char(50);
define _ajustador	     char(50);
define _producto         char(50);
define _no_documento	 char(20);
define _cod_asignacion	 char(10);
define _cod_asegurado	 char(10);
define _cod_reclamante	 char(10);
define _cod_entrada		 char(10);
define _no_poliza		 char(10);
define _no_unidad		 char(10);
define _cod_producto     char(5);
define _cod_agente		 char(5);
define _cod_ajustador    char(3);
define _cod_formapag     char(3);
define _cod_tipopago     char(3);
define _cobrador		 char(3);
define _cobra_poliza     char(1);
define _monto			 dec(16,2);
define _saldo			 dec(16,2);
define _suspenso		 smallint;
define _valor            smallint;
define _cantidad	     integer;
define _date_added       datetime year to fraction(5);

set isolation to dirty read;

--set debug file to "sp_rec138.trc";
--trace on;

let _cantidad   = 0;
let _nom_corredor = "";
let _saldo = 0;

select count(*)			--busca si hay pendientes.
  into _cantidad
  from atcdocde
 where completado = 0
   and en_mora = 1;

if _cantidad > 0 then	--hay pendiente, mandar mensaje y ese es el que se muestra.

   let _valor = sp_rec138b();

   foreach
		select cod_asignacion,
			   date_added,
			   no_documento,
			   no_unidad,
			   cod_asegurado,
			   cod_reclamante,
			   cod_ajustador,
			   cod_entrada,
			   suspenso,
			   monto,
			   obs_mora,
			   cod_tipopago
		  into _cod_asignacion,
		       _date_added,
			   _no_documento,
			   _no_unidad,
			   _cod_asegurado,
			   _cod_reclamante,
			   _cod_ajustador,
			   _cod_entrada,
			   _suspenso,
			   _monto,
			   _obs_mora,
			   _cod_tipopago
		  from atcdocde
		 where completado         = 0
		   and en_mora            = 1
		 order by date_added

		let _no_poliza = sp_sis21(_no_documento);

		select cobra_poliza,
			   cod_formapag
		  into _cobra_poliza,
		       _cod_formapag
		  from emipomae
		 where no_poliza = _no_poliza;

		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			  exit foreach;
		end foreach

		select cod_cobrador
		  into _cobrador
		  from agtagent
		 where cod_agente = _cod_agente;

		select nombre
		  into _asegurado
		  from cliclien
		 where cod_cliente = _cod_asegurado;

		select nombre
		  into _reclamante
		  from cliclien
		 where cod_cliente = _cod_reclamante;

		select nombre
		  into _ajustador
		  from recajust
		 where cod_ajustador = _cod_ajustador;

		if _suspenso is null then
			let _suspenso = 0;
		end if

		if _monto is null then
			let _monto = 0;
		end if

		if _cobra_poliza = 'E' then
			let _nom_cobrador     = 'CALL CENTER';
		elif _cobra_poliza = 'G' then
			let _nom_cobrador     = 'GERENCIA';
		elif _cobra_poliza = 'I' then            
			let _nom_cobrador     = 'INCOBRABLES'; 
		elif _cobra_poliza = 'T' then
			let _nom_cobrador     = 'TARJETA CREDITO'; 
		elif _cobra_poliza = 'H' then
			let _nom_cobrador     = 'ACH'; 
		elif _cobra_poliza = 'P' then
			let _nom_cobrador     = 'POR CANCELAR';
		elif _cobra_poliza = 'Z' then
			let _nom_cobrador     = 'COASEGURO MINORITARIO';
		else
			select nombre 
			  into _nom_cobrador
			  from cobcobra
			 where cod_cobrador = _cobrador;
		end if

		select nombre
	      into _nom_corredor
		  from agtagent
	     where cod_agente = _cod_agente;

		select saldo
		  into _saldo
		  from tmp_s
		 where no_documento   = _no_documento
		   and cod_asignacion = _cod_asignacion;

		let _nom_formapag = "";

        select nombre
		  into _nom_formapag
		  from cobforpa
		 where cod_formapag = _cod_formapag;


		return	0,
				_cod_asignacion,
				_no_documento,
				_no_unidad,
				_cod_asegurado,
				_cod_reclamante,
				_asegurado,
				_reclamante,
				_monto,
				_no_poliza,
				_cod_entrada,
				_suspenso,
				_ajustador,
				_date_added,
				_obs_mora,
				_cod_tipopago,
				_nom_cobrador,
				_nom_corredor,
				_saldo,
				_nom_formapag
				with resume;
	end foreach
	drop table tmp_s;
else
--	return 1,"","","","","","","",0,"","",0;
end if

end procedure;