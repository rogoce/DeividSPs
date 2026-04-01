-- Cambia el Cobra de Polizas dependiendo de diferentes condicones
-- 
-- Creado    : 29/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 29/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas011;

create procedure sp_cas011()
returning char(50);

define _doc_poliza		char(20);		  
define _no_poliza		char(10);
define _incobrable		smallint;
define _cod_formapag	char(3);
define _tipo_forma		smallint;
define _cod_agente		char(5);
define _cobra_poliza	char(1);
define _cobra_poliza2	char(1);
define _cod_tipoprod	char(3);
define _formapag        char(2);

define _asignado		smallint;
define _cantidad        integer;
define _gestion			char(1);

let _cantidad = 0;

set isolation to dirty read;

foreach 
 select no_documento
   into	_doc_poliza
   from emipomae 
  where actualizado = 1
  group by no_documento		

	let _no_poliza = sp_sis21(_doc_poliza);

	select incobrable,
	       cobra_poliza,
		   cod_formapag,
		   cod_tipoprod,
		   gestion
	  into _incobrable,
	       _cobra_poliza2,
		   _cod_formapag,
		   _cod_tipoprod,
		   _gestion
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if

	let _cantidad = _cantidad + 1;

	select tipo_forma
	  into _tipo_forma
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	let _cod_agente = null;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
		exit foreach;
	end foreach

	let _asignado = 0;

	---------------------
	-- Cobros de Gerencia
	---------------------

	if _cod_agente = "00001" then
		
		let _asignado     = 1;
		let _cobra_poliza = "G";

	end if


	if _asignado = 0 then

		if _doc_poliza = "1799-00027-01" or
		   _doc_poliza = "1702-00001-01" or
		   _doc_poliza = "0201-00944-01" or
		   _doc_poliza = "0202-00933-01" or
		   _doc_poliza = "0902-00030-01" or
		   _doc_poliza = "0801-01899-01" or
		   _doc_poliza = "0202-00890-01" or
		   _doc_poliza = "0902-00034-01" or
		   _doc_poliza = "1602-00015-01" then

			let _asignado     = 1;
			let _cobra_poliza = "G";

		end if

	end if

	--------------
	-- Incobrables
	--------------

	if _asignado = 0 then

		if _incobrable = 1 then

			let _asignado     = 1;
			let _cobra_poliza = "I";

		end if

	end if

	-------------------------
	-- Por Cancelar y Legales
	-------------------------

	if _asignado = 0 then

		if _gestion = "C" or
		   _gestion = "L" then

			let _asignado     = 1;
			let _cobra_poliza = "P";

		end if

	end if

	----------------------
	-- Tarjetas de Credito
	----------------------

	if _asignado = 0 then

		if _tipo_forma = 2 then	-- Tarjetas de Credito
		
			let _asignado     = 1;
			let _cobra_poliza = "T";

		end if
		
	end if

	------
	-- ACH
	------

	if _asignado = 0 then

		if _tipo_forma = 4 then -- ACH

			let _asignado     = 1;
			let _cobra_poliza = "H";

		end if
		
	end if

	-----------------------------
	-- Gestores por Forma de Pago
	-----------------------------

	if _asignado = 0 then
	
		if _tipo_forma = 5 then

			let _asignado     = 1;
			let _cobra_poliza = "E";

		end if
		
	end if

	-------------------------------
	-- Corredores por Forma de Pago
	-------------------------------

	if _asignado = 0 then

		if _tipo_forma = 6 then

			let _asignado     = 1;
			let _cobra_poliza = "C";

		end if

	end if

	------------------------
	-- Gestores por Corredor
	------------------------

	if _asignado = 0 then

		if _cod_agente = "00099" or
	       _cod_agente = "00731" or
	       _cod_agente = "00287" or
	       _cod_agente = "00557" or
	       _cod_agente = "00892" or
	       _cod_agente = "00238" or
	       _cod_agente = "00195" or
	       _cod_agente = "00778" or
	       _cod_agente = "00608" or
	       _cod_agente = "00433" or
	       _cod_agente = "00402" or
	       _cod_agente = "00488" or
	       _cod_agente = "00062" or
	       _cod_agente = "00846" or
	       _cod_agente = "00068" or
	       _cod_agente = "00632" or
	       _cod_agente = "00523" or
	       _cod_agente = "00286" or
	       _cod_agente = "00514" or
	       _cod_agente = "00033" or
	       _cod_agente = "00225" or
	       _cod_agente = "00021" or
	       _cod_agente = "00746" or
	       _cod_agente = "00674" or
	       _cod_agente = "00703" or
	       _cod_agente = "00207" or
	       _cod_agente = "00530" or
	       _cod_agente = "00628" or
	       _cod_agente = "00859" or
	       _cod_agente = "00767" or
	       _cod_agente = "00636" or
	       _cod_agente = "00761" or
	       _cod_agente = "00517" or
	       _cod_agente = "00622" or
	       _cod_agente = "00492" or
	       _cod_agente = "00562" or
	       _cod_agente = "00418" or
	       _cod_agente = "00662" or
	       _cod_agente = "00787" or
	       _cod_agente = "00279" or
	       _cod_agente = "00677" or
	       _cod_agente = "00734" or
	       _cod_agente = "00041" or
	       _cod_agente = "00166" or
	       _cod_agente = "00705" or
	       _cod_agente = "00234" or
	       _cod_agente = "00471" or
	       _cod_agente = "00780" or
	       _cod_agente = "00696" or
	       _cod_agente = "00243" or
	       _cod_agente = "00090" or
	       _cod_agente = "00071" or
	       _cod_agente = "00516" or
	       _cod_agente = "00595" or
	       _cod_agente = "00605" or
	       _cod_agente = "00006" or
	       _cod_agente = "00011" or
	       _cod_agente = "00078" or
	       _cod_agente = "00708" or
	       _cod_agente = "00412" or
	       _cod_agente = "00897" or
	       _cod_agente = "00518" or
	       _cod_agente = "00762" or
	       _cod_agente = "00751" or
	       _cod_agente = "00606" or
	       _cod_agente = "00400" or
	       _cod_agente = "00273" then

			let _asignado     = 1;
			let _cobra_poliza = "E";

		end if
		
	end if

	--------------------------
	-- Corredores por Corredor
	--------------------------

	if _asignado = 0 then

		if _cod_agente = "00269" or
		   _cod_agente = "00081" or
		   _cod_agente = "00547" or
		   _cod_agente = "00224" or
		   _cod_agente = "00008" or
		   _cod_agente = "00247" or
		   _cod_agente = "00248" or
		   _cod_agente = "00623" or
		   _cod_agente = "00012" or
		   _cod_agente = "00200" or
		   _cod_agente = "00815" or
		   _cod_agente = "00521" or
		   _cod_agente = "00727" or
		   _cod_agente = "00161" or
		   _cod_agente = "00146" or
		   _cod_agente = "00270" or
		   _cod_agente = "00540" or
		   _cod_agente = "00153" or
		   _cod_agente = "00133" or
		   _cod_agente = "00370" or
		   _cod_agente = "00035" or
		   _cod_agente = "00817" or
		   _cod_agente = "00119" or
		   _cod_agente = "00107" or
		   _cod_agente = "00037" or
		   _cod_agente = "00732" or
		   _cod_agente = "00184" or
		   _cod_agente = "00235" or
		   _cod_agente = "00853" or
		   _cod_agente = "00125" or
		   _cod_agente = "00007" or
		   _cod_agente = "00180" or
		   _cod_agente = "00141" or
		   _cod_agente = "00567" or
	       _cod_agente = "00031" or
	       _cod_agente = "00176" or
	       _cod_agente = "00083" or
	       _cod_agente = "00779" or
	       _cod_agente = "00429" then

			let _asignado     = 1;
			let _cobra_poliza = "C";

		end if

	end if

	if _asignado = 0 then
		let _cobra_poliza = "A";
	end if

--{

	update emipomae
	   set cobra_poliza = _cobra_poliza
	 where no_poliza    = _no_poliza;

--}

end foreach

return _cantidad || " Registros Procesados ...";

end procedure
