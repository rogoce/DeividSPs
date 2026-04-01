-- Depuracion de la tabla de Clientes
-- Creado         : 06/04/2005 - Autor: Demetrio Hurtado Almanza 
-- Modificado Por : 11/10/2007 - Rub‚n Arn ez
drop procedure sp_sis73;

create procedure "informix".sp_sis73(
a_cod_errado	char(10), 
a_cod_correcto 	char(10),
a_user			char(8)
) returning integer,
char(100);

define _error         integer;
define _cod_cliente   char(10);
define _nombre        char(30);
define _cod_errado    char(10);
define _cod_correcto  char(10);
define _tiempo	      datetime year to fraction(5);
define _nom_tabla     char(30);
define _no_doc		  char(20); 
define _cnt			  integer;
define _no_documento  char(20);

define _dia_cobros1  smallint;
define _dia_cobros2  smallint;
define _a_pagar      decimal(16,2);
define _tipo_mov     char(1);

let _tiempo         = current;
let _nombre         = "";
let _cod_errado     = "";
let _cod_correcto   = "";
let _nom_tabla      = "";

CREATE TEMP TABLE tmp_hijo(
no_documento         char(20),
cod_cliente          char(10),
dia_cobros1          smallint,
dia_cobros2          smallint,
a_pagar              decimal(16,2),
tipo_mov             char(1)
) WITH NO LOG;	  
{
begin work;

begin
on exception set _error
rollback work;
return _error, "Error al Actualizar el Registro";
end exception
}


		select count(*)
		into _cnt
		from bkcavica
		where cod_pagador = a_cod_errado;

		if _cnt > 0 then
		let _nom_tabla = "bkcavica";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_documento
			from bkcavica
			where cod_pagador = a_cod_errado;


			update bkcavica
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from chqchmae
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then
		let _nom_tabla = "chqchmae";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_requis
			from chqchmae
			where cod_cliente = a_cod_errado;


			update chqchmae
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if
		let _cnt = 0;
		select count(*)
		into _cnt
		from tcliclicl
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "cliclicl";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_clasecli,
			cod_cliente
			from  cliclicl
			where  cod_cliente = a_cod_errado;


			update cliclicl
			   set cod_cliente = a_cod_correcto
			 where cod_cliente = a_cod_errado;

		end if 


		let _cnt = 0;
		select count(*)
		into _cnt
		from clicolat
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "clicolat";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_cliente,
			cod_tipogar
			from  clicolat
			where cod_cliente = a_cod_errado;

			update clicolat
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from cobavica
		where cod_pagador = a_cod_errado;

		if _cnt > 0 then
		let _nom_tabla = "cobavica";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_documento
			from cobavica
			where cod_pagador = a_cod_errado;

			update cobavica
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from cobaviso
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "cobaviso";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_cobrador,
			no_poliza
			from  cobaviso
			where  cod_pagador = a_cod_errado;

			update cobaviso
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from cobca90p
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "cobca90p";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_cliente
			from  cobca90p
			where  cod_cliente = a_cod_errado;


			update cobca90p
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
			into _cnt
			from cobcacam
			where cod_cliente = a_cod_errado;

			if _cnt > 0 then

			let _nom_tabla = "cobcacam";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			key_fecha
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_cliente,
			fecha
			from  cobcacam
			where  cod_cliente = a_cod_errado;

			update cobcacam
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;
		end if


		let _cnt = 0;

		select count(*)
		into _cnt
		from cobcahis
		where cod_pagador = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "cobcahis";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_gestion
			from  cobcahis
			where  cod_pagador = a_cod_errado;

			update cobcahis
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from cobcampl
		where cod_pagador = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "cobcampl";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_documento,
			no_cambio

			from  cobcampl
			where  cod_pagador = a_cod_errado;

			update cobcampl
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from cobcapen
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "cobcapen";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_cliente
			from  cobcapen
			where  cod_cliente = a_cod_errado;

			update cobcapen
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if


		let _cnt = 0;

		select count(*)
		into _cnt
		from cobcatmp
		where cod_pagador = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "cobcatmp";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_documento
			from  cobcatmp
			where  cod_pagador = a_cod_errado;

			update cobcatmp
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from cobcatmp3
		where cod_pagador = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "cobcatmp3";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_pagador
			from  cobcatmp3
			where  cod_pagador = a_cod_errado;

			update cobcatmp3
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from cobcuhab
		where cod_pagador = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "cobcuhab";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_cuenta
			from  cobcuhab
			where  cod_pagador = a_cod_errado;

			update cobcuhab
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from cobcupag
		where cod_pagador = a_cod_errado;
		   
		if _cnt > 0 then

		let _nom_tabla = "cobcupag";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_cuenta
			from  cobcupag
			where  cod_pagador = a_cod_errado;

			update cobcupag
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from cobcutmp
		where cod_pagador = a_cod_errado;
		   
		if _cnt > 0 then

		let _nom_tabla = "cobcutmp";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_tran
			from  cobcutmp
			where  cod_pagador = a_cod_errado;

			update cobcutmp
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from cobcutra
		where cod_pagador = a_cod_errado;
		   
		if _cnt > 0 then

		let _nom_tabla = "cobcutra";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_cuenta,
			no_documento
			from  cobcutra
			where  cod_pagador = a_cod_errado;

			update cobcutra
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from cobgesti
		where cod_pagador = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "cobgesti";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			key_fecha
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza,
			fecha_gestion
			from  cobgesti
			where  cod_pagador = a_cod_errado;

			update cobgesti
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from cobgesti2
		where cod_pagador = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "cobgesti2";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			key_fecha
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza,
			fecha_gestion

			from  cobgesti2
			where  cod_pagador = a_cod_errado;

			update cobgesti2
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from cobredet
		where cod_recibi_de = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "cobredet";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			key_renglon
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_remesa,
			renglon
			from  cobredet
			where  cod_recibi_de = a_cod_errado;


			update cobredet
			set cod_recibi_de = a_cod_correcto
			where cod_recibi_de = a_cod_errado;

		end if
		
		let _cnt = 0;
		select count(*)
		into _cnt
		from cobruhis
		where cod_pagador = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "cobruhis";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			key_renglon,
			key_fecha
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_cobrador,
			dia_cobros1,
			fecha

			from  cobruhis
			where  cod_pagador = a_cod_errado;

			update cobruhis
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from cobruter
		where cod_pagador = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "cobruter";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			key_renglon,
			key_fecha
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_cobrador,
			dia_cobros1,
			fecha
			from  cobruter
			where  cod_pagador = a_cod_errado;

			update cobruter
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from cobruter1
		where cod_pagador = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "cobruter1";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			key_renglon,
			key_fecha
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_cobrador,
			dia_cobros1,
			fecha
			from  cobruter1
			where  cod_pagador = a_cod_errado;

			update cobruter1
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if


		let _cnt = 0;

		select count(*)
		into _cnt
		from cobruter2
		where cod_pagador = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "cobruter2";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			key_renglon,
			key_fecha
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_cobrador,
			dia_cobros1,
			fecha
			from  cobruter2
			where  cod_pagador = a_cod_errado;

			update cobruter2
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from diariobk
		where cod_pagador = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "diariobk";


			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab					)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_pagador,
			cod_cobrador
			from  diariobk
			where  cod_pagador = a_cod_errado;

			update diariobk
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if


		let _cnt = 0;

		select count(*)
		into _cnt
		from diariobk
		where cod_pagador = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "emibenef";


			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab					)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_pagador,
			cod_cobrador
			from  diariobk
			where  cod_pagador = a_cod_errado;

			update diariobk
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from emibenef
		where cod_cliente = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "emibenef";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza,
			no_unidad
			from  emibenef
			where cod_cliente = a_cod_errado;

			update emibenef
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from emidepen
		where cod_cliente = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "emidepen";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza,
			no_unidad
			from  emidepen
			where  cod_cliente = a_cod_errado;

			update emidepen
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from emipomae
		where cod_contratante = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "emipomae-contr";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza
			from  emipomae
			where  cod_contratante = a_cod_errado;

			update 	emipomae
			set 	cod_contratante = a_cod_correcto
			where 	cod_contratante = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from emipomae
		where cod_pagador = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "emipomae-pagad";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza
			  from  emipomae
			 where  cod_pagador = a_cod_errado;

			update emipomae
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from emiporen
		where cod_contratante = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "emiporen-contra";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza
			from  emiporen
			where  cod_contratante = a_cod_errado;

			update emiporen
			set cod_contratante = a_cod_correcto
			where cod_contratante = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from emiporen
		where cod_pagador = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "emiporen-pagador";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza
			  from  emiporen
			 where  cod_pagador = a_cod_errado;

			update emiporen
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from emipouni
		where cod_asegurado = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "emipouni";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza,
			no_unidad
			from  emipouni
			where  cod_asegurado = a_cod_errado;

			update emipouni
			   set cod_asegurado = a_cod_correcto
			 where cod_asegurado = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from emiprede
		where cod_cliente = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "emiprede";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab,
			te_key_tab,
			cu_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza,
			no_unidad,
			cod_cliente,
			cod_procedimiento
			from  emiprede
			where  cod_cliente = a_cod_errado;

			update emiprede
			   set cod_cliente = a_cod_correcto
			 where cod_cliente = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from emireaut
		where cod_asegurado = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "emireaut";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
				)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza
			from  emireaut
			where  cod_asegurado = a_cod_errado;

			update emireaut
			   set cod_asegurado = a_cod_correcto
			 where cod_asegurado = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from endbenef
		where cod_cliente = a_cod_errado;
			   
		if _cnt > 0 then

		let _nom_tabla = "endbenef";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab,
			te_key_tab,
			cu_key_tab
				)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza,
			no_endoso,
			no_unidad,
			cod_cliente
			from  endbenef
			where  cod_cliente = a_cod_errado;

			update endbenef
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from endeduni
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "endeduni";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab,
			te_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza,
			no_endoso,
			no_unidad,
			cod_tipogar
			from  endeduni
			where  cod_cliente = a_cod_errado;

			update endeduni
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if 


		let _cnt = 0;
		select count(*)
		into _cnt
		from endmoase
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "endmoase";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_poliza,
			no_endoso
			from  endmoase
			where  cod_cliente = a_cod_errado;

			update endmoase
			   set cod_cliente = a_cod_correcto
			 where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from recacuan
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recacuan";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			anio,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_documento,
			ano,
			cod_cliente
			from  recacuan
			where  cod_cliente = a_cod_errado;

			update recacuan
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from recacusu
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recacusu";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			anio,
			se_key_tab,
			te_key_tab,
			cu_key_tab

			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_documento,
			ano,
			cod_cliente,
			cod_cobertura
			from  recacusu
			where  cod_cliente = a_cod_errado;

			update recacusu
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if	


		let _cnt = 0;
		select count(*)
		into _cnt
		from recacuvi
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recacuvi";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab,
			te_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_documento,
			cod_cliente,
			cod_cobertura
			from  recacuvi
			where  cod_cliente = a_cod_errado;

			update recacuvi
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from recdeacu
		where cod_reclamante = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recdeacu";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab,
			te_key_tab,
			anio
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_reclamante,
			no_poliza,
			cod_cobertura,
			ano
			from  recdeacu
			where  cod_reclamante = a_cod_errado;


			update recdeacu
			set cod_reclamante = a_cod_correcto
			where cod_reclamante = a_cod_errado;


		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from recordma
		where cod_proveedor = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recordma";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			no_orden
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_orden

			from  recordma
			where  cod_proveedor = a_cod_errado;

			update recordma
			set cod_proveedor = a_cod_correcto
			where cod_proveedor = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from recpcota
		where cod_proveedor = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recpcota";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_cot_piezas,
			cod_proveedor

			from  recpcota
			where  cod_proveedor = a_cod_errado;

			update recpcota
			set cod_proveedor = a_cod_correcto
			where cod_proveedor = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from recprove
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recprove";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cedula
			from  recprove
			where  cod_cliente = a_cod_errado;

			update recprove
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from recrcmae
		where cod_asegurado = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recrcmae-aseg";
			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_reclamo
			from  recrcmae
			where cod_asegurado = a_cod_errado;

			update recrcmae
			set cod_asegurado = a_cod_correcto
			where cod_asegurado = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from recrcmae
		where cod_conductor = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recrcmae-cond";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_reclamo
			from  recrcmae
			where  cod_conductor = a_cod_errado;

			update recrcmae
			set cod_conductor = a_cod_correcto
			where cod_conductor = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from recrcmae
		where cod_doctor = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recrcmae-doct";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_reclamo
			from  recrcmae
			where  cod_doctor = a_cod_errado;

			update recrcmae
			set cod_doctor = a_cod_correcto
			where cod_doctor = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from recrcmae
		where cod_hospital = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recrcmae-hosp";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_reclamo
			from  recrcmae
			where  cod_hospital = a_cod_errado;

			update recrcmae
			set cod_hospital = a_cod_correcto
			where cod_hospital = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from recrcmae
		where cod_reclamante = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recrcmae-reclam";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_reclamo
			from  recrcmae
			where  cod_reclamante = a_cod_errado;

			update recrcmae
			set cod_reclamante = a_cod_correcto
			where cod_reclamante = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from recrcmae
		where cod_taller = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recrcmae-taller";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_reclamo
			from  recrcmae
			where  cod_taller = a_cod_errado;

			update recrcmae
			set cod_taller = a_cod_correcto
			where cod_taller = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from recrcoma
		where cod_taller = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recrcoma-taller";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_cot_rep
			from  recrcoma
			where  cod_taller = a_cod_errado;

			update recrcoma
			set cod_taller = a_cod_correcto 	 
			where cod_taller = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from recrcoma
		where cod_tercero = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recrcoma-tercer";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_cot_rep
			from 	recrcoma
			where  cod_tercero = a_cod_errado ;

			update  recrcoma
			set  cod_tercero = a_cod_correcto	
			where  cod_tercero = a_cod_errado;

		end if


		let _cnt = 0;

		select count(*)
		into _cnt
		from recterce
		where cod_conductor = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recterce-con";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_reclamo,
			cod_tercero
			from  recterce
			where cod_conductor = a_cod_errado;

			update recterce
			   set cod_conductor = a_cod_correcto
			 where cod_conductor = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		  into _cnt
	      from recterce
		 where cod_tercero = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "recterce-ter";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_reclamo,
			cod_tercero
			from  recterce
			where  cod_tercero = a_cod_errado;


			update  recterce						  
			set  cod_tercero = a_cod_correcto
			where  cod_tercero = a_cod_errado;

		end if



		let _cnt = 0;

		select count(*)
		into _cnt
		from rectrmae
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "rectrmae-clt";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_tranrec
			from  rectrmae
			where  cod_cliente = a_cod_errado;


			update rectrmae
			set cod_cliente = a_cod_correcto	  
			where cod_cliente = a_cod_errado;

		end if


		let _cnt = 0;

		select count(*)
		into _cnt
		from rectrmae
		where cod_proveedor = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "rectrmae-prov";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			no_tranrec
			from  rectrmae
			where  cod_proveedor = a_cod_errado;

			update rectrmae
			set cod_proveedor = a_cod_correcto 
			where cod_proveedor = a_cod_errado;

		end if


--update tmp_cartadet				  -- NOTA ESTA TABLA NO EXITE PREGUNTAR A DEMETRIO 
--			update tmp_cartadet
--			   set cod_cliente = a_cod_correcto	  
--			 where cod_cliente = a_cod_errado;


		let _cnt = 0;

		select count(*)
		into _cnt
		from wf_db_autos
		where codcliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "wf_db_autos";

			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab,
			te_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			name,
			nrocotizacion,
			codcliente
			from  wf_db_autos
			where  codcliente = a_cod_errado;


			update wf_db_autos
			set codcliente = a_cod_correcto	 
			where codcliente = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from wf_db_autos
		where codcliente = a_cod_errado;

		if _cnt > 0 then

		let _nom_tabla = "wf_ordcomp";


			insert into tclidepur2
			(
			cod_errado,
			cod_correcto,
			user_changed,
			date_changed,
			nom_tabla,
			pr_key_tab,
			se_key_tab,
			te_key_tab
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			wf_incidente,
			wf_proveedor,
			wf_pieza

			from  wf_db_autos
			where  codcliente = a_cod_errado;

			update wf_ordcomp					 
			set codcliente = a_cod_correcto
			where codcliente = a_cod_errado;

		end if



		let _cnt = 0;
		select count(*)
		  into _cnt
		  from caspoliza
		 where cod_cliente = a_cod_errado;
			   
		if _cnt > 0 then

		insert into tmp_hijo
		select no_documento, cod_cliente, dia_cobros1, dia_cobros2, a_pagar, tipo_mov
		from caspoliza
		where cod_cliente = a_cod_errado;

		end if

		delete from caspoliza
	     where cod_cliente = a_cod_errado;

		update cascliente
		set cod_cliente = a_cod_correcto
		where cod_cliente = a_cod_errado; 

		update tmp_hijo
		   set cod_cliente = a_cod_correcto
		 where cod_cliente = a_cod_errado;

		insert into caspoliza
		select no_documento, cod_cliente, dia_cobros1, dia_cobros2, a_pagar, tipo_mov
		from tmp_hijo;

		drop table tmp_hijo;


		delete from cliclien
		where cod_cliente = a_cod_errado;

-- end

-- rollback work;
-- return 0, "Actualizacion Exitosa";
end procedure



