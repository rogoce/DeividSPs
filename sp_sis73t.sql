-- Depuraci¢n de la Tabla de Clientes
-- Creado         : 06/04/2005 - Autor: Demetrio Hurtado Almanza 
-- Modificado Por : 11/10/2007 - Rub‚n Arn ez

drop procedure sp_sis73t;

create procedure "informix".sp_sis73t(a_cod_errado char(10), a_cod_correcto char(10), a_user char(8))
returning integer,
char(100);


{
create procedure "informix".sp_sis73t()
returning integer,
        char(100);
}

define _error		  integer;
define _cod_cliente   char(10);
define _nombre        char(30);
define _cod_errado    char(10);
define _cod_correcto  char(10);
define _tiempo	      datetime year to fraction(5);
define _nom_tabla     char(30);
define _no_doc		  char(20); 
define _cnt			  integer;
define _no_documento  char(20);

define _dia_cobros1   smallint;
define _dia_cobros2   smallint;
define _a_pagar       decimal(16,2);
define _tipo_mov      char(1);


let _tiempo        = current;
let _nombre        = "";
let _cod_errado    = "";
let _cod_correcto  = "";
let _nom_tabla     = "";

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_sis73a.trc";
--TRACE ON;

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


foreach 
     select cod_errado,
			cod_leasin
	   into a_cod_errado,
			a_cod_correcto
	   from leasing

}


		select count(*)
		into _cnt
		from tbkcavica
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
			from tbkcavica
			where cod_pagador = a_cod_errado;


			update tbkcavica
			set cod_pagador   = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from tchqchmae
		where cod_cliente = a_cod_errado;

		if _cnt > 0 then
		let _nom_tabla    = "chqchmae";

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
			from tchqchmae
			where cod_cliente  = a_cod_errado;


			update tchqchmae
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
			from  tcliclicl
			where cod_cliente = a_cod_errado;


			update tcliclicl
			set cod_cliente   = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if 


		let _cnt = 0;
		select count(*)
		into _cnt
		from tclicolat
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
			from tclicolat
			where cod_cliente = a_cod_errado;

			update tclicolat
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from tcobavica
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
			from tcobavica
			where cod_pagador = a_cod_errado;

			update tcobavica
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from tcobaviso
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
			from  tcobaviso
			where  cod_cliente = a_cod_errado;

			update tcobaviso
			set cod_cliente   = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from tcobca90p
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
			from  tcobca90p
			where cod_cliente = a_cod_errado;


			update tcobca90p
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
			into _cnt
			from tcobcacam
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
			from  tcobcacam
			where  cod_cliente = a_cod_errado;

			update tcobcacam
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;
		end if


		let _cnt = 0;

		select count(*)
		into _cnt
		from tcobcahis
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
			from  tcobcahis
			where cod_pagador = a_cod_errado;

			update tcobcahis
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		  into _cnt
		  from tcobcampl
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

			from  tcobcampl
			where cod_pagador = a_cod_errado;

			update tcobcampl
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from tcobcapen
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
			from  tcobcapen
			where cod_cliente = a_cod_errado;

			update tcobcapen
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if


		let _cnt = 0;

		select count(*)
		  into _cnt
		  from tcobcatmp
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
			from  tcobcatmp
			where  cod_pagador = a_cod_errado;

			update tcobcatmp
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from tcobcatmp3
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
			from  tcobcatmp3
			where cod_pagador = a_cod_errado;

			update tcobcatmp3
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		  into _cnt
		  from tcobcuhab
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
			from  tcobcuhab
			where cod_pagador = a_cod_errado;

			update tcobcuhab
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcobcupag
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
			from  tcobcupag
			where cod_pagador = a_cod_errado;

			update tcobcupag
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcobcutmp
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
			from  tcobcutmp
			where cod_pagador = a_cod_errado;

			update tcobcutmp
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcobcutra
		 where cod_pagador = a_cod_errado;
		   
		if _cnt > 0 then

		let _nom_tabla = "tcobcutra";

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
			from  tcobcutra
			where cod_pagador = a_cod_errado;

			update tcobcutra
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		  into _cnt
		from  tcobgesti
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
			from  tcobgesti
			where cod_pagador = a_cod_errado;

			update tcobgesti
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcobgesti2
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

			from  tcobgesti2
			where cod_pagador = a_cod_errado;

			update tcobgesti2
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcobredet
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
			from  tcobredet
			where cod_recibi_de = a_cod_errado;


			update tcobredet
			   set cod_recibi_de = a_cod_correcto
			 where cod_recibi_de = a_cod_errado;

		end if
		
		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcobruhis
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

			from  tcobruhis
			where cod_pagador = a_cod_errado;

			update tcobruhis
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcobruter
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
			from  tcobruter
			where cod_pagador = a_cod_errado;

			update tcobruter
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcobruter1
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
			from  tcobruter1
			where cod_pagador = a_cod_errado;

			update tcobruter1
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if


		let _cnt = 0;

		select count(*)
		  into _cnt
		  from tcobruter2
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
			from  tcobruter2
			where cod_pagador = a_cod_errado;

			update tcobruter2
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from tdiariobk
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
			 from tdiariobk
			where cod_pagador = a_cod_errado;

			update tdiariobk
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if


		let _cnt = 0;

		select count(*)
		into _cnt
		from tdiariobk
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
			se_key_tab					
			)
			select 
			a_cod_errado,
			a_cod_correcto,
			a_user,
			_tiempo,
			_nom_tabla,
			cod_pagador,
			cod_cobrador
			from  tdiariobk
			where cod_pagador = a_cod_errado;

			update tdiariobk
			set cod_pagador = a_cod_correcto
			where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from temibenef
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
			from  temibenef
			where cod_cliente = a_cod_errado;

			update temibenef
			   set cod_cliente = a_cod_correcto
			 where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from temidepen
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
			from  temidepen
			where cod_cliente = a_cod_errado;

			update temidepen
			   set cod_cliente = a_cod_correcto
			 where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		  into _cnt
		  from temipomae
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
			from  temipomae
			where cod_contratante = a_cod_errado;

			update 	temipomae
			set 	cod_contratante = a_cod_correcto
			where 	cod_contratante = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from temipomae
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
			  from  temipomae
			 where  cod_pagador = a_cod_errado;

			update temipomae
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from temiporen
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
			from  temiporen
			where cod_contratante = a_cod_errado;

			update temiporen
			set cod_contratante = a_cod_correcto
			where cod_contratante = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from temiporen
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
			  from  temiporen
			 where  cod_pagador = a_cod_errado;

			update temiporen
			   set cod_pagador = a_cod_correcto
			 where cod_pagador = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from temipouni
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
			from  temipouni
			where  cod_asegurado = a_cod_errado;

			update temipouni
			   set cod_asegurado = a_cod_correcto
			 where cod_asegurado = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from temiprede
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
			from  temiprede
			where cod_cliente = a_cod_errado;

			update temiprede
			   set cod_cliente = a_cod_correcto
			 where cod_cliente = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from temireaut
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
			from  temireaut
			where cod_asegurado = a_cod_errado;

			update temireaut
			   set cod_asegurado = a_cod_correcto
			 where cod_asegurado = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from tendbenef
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
			from  tendbenef
			where cod_cliente = a_cod_errado;

			update tendbenef
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from tendeduni
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
			from  tendeduni
			where cod_cliente = a_cod_errado;

			update tendeduni
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if 


		let _cnt = 0;
		select count(*)
		into _cnt
		from  tendmoase
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
			from  tendmoase
			where cod_cliente = a_cod_errado;

			update tendmoase
			   set cod_cliente = a_cod_correcto
			 where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from trecacuan
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
			from  trecacuan
			where cod_cliente = a_cod_errado;

			update trecacuan
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from trecacusu
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
			from  trecacusu
			where cod_cliente = a_cod_errado;

			update trecacusu
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if	


		let _cnt = 0;
		select count(*)
		into _cnt
		from trecacuvi
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
			from  trecacuvi
			where cod_cliente = a_cod_errado;

			update trecacuvi
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from trecdeacu
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
			from  trecdeacu
			where cod_reclamante = a_cod_errado;


			update trecdeacu
			set cod_reclamante = a_cod_correcto
			where cod_reclamante = a_cod_errado;


		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from trecordma
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

			from  trecordma
			where cod_proveedor = a_cod_errado;

			update trecordma
			set cod_proveedor = a_cod_correcto
			where cod_proveedor = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from trecpcota
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

			from  trecpcota
			where cod_proveedor = a_cod_errado;

			update trecpcota
			set cod_proveedor = a_cod_correcto
			where cod_proveedor = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from trecprove
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
			from  trecprove
			where cod_cliente = a_cod_errado;

			update trecprove
			set cod_cliente = a_cod_correcto
			where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		into _cnt
		from trecrcmae
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
			from  trecrcmae
			where cod_asegurado = a_cod_errado;

			update trecrcmae
			set cod_asegurado = a_cod_correcto
			where cod_asegurado = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from trecrcmae
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
			from  trecrcmae
			where cod_conductor = a_cod_errado;

			update trecrcmae
			set cod_conductor = a_cod_correcto
			where cod_conductor = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from trecrcmae
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
			from  trecrcmae
			where cod_doctor = a_cod_errado;

			update trecrcmae
			set cod_doctor = a_cod_correcto
			where cod_doctor = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from trecrcmae
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
			from  trecrcmae
			where  cod_hospital = a_cod_errado;

			update trecrcmae
			set cod_hospital = a_cod_correcto
			where cod_hospital = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from trecrcmae
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
			from  trecrcmae
			where cod_reclamante = a_cod_errado;

			update trecrcmae
			set cod_reclamante = a_cod_correcto
			where cod_reclamante = a_cod_errado;

		end if


		let _cnt = 0;
		select count(*)
		into _cnt
		from trecrcmae
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
			from  trecrcmae
			where cod_taller = a_cod_errado;

			update trecrcmae
			set cod_taller = a_cod_correcto
			where cod_taller = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		  into _cnt
		  from trecrcoma
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
			from  trecrcoma
			where cod_taller = a_cod_errado;

			update trecrcoma
			   set cod_taller = a_cod_correcto 	 
			 where cod_taller = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		  into _cnt
		  from trecrcoma
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
			from   trecrcoma
			where  cod_tercero = a_cod_errado ;

			update trecrcoma
			set  cod_tercero = a_cod_correcto	
			where  cod_tercero = a_cod_errado;

		end if


		let _cnt = 0;

		select count(*)
		  into _cnt
		  from trecterce
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
			from  trecterce
			where cod_conductor = a_cod_errado;

			update trecterce
			   set cod_conductor = a_cod_correcto
			 where cod_conductor = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		  into _cnt
	      from trecterce
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
			from  trecterce
			where cod_tercero = a_cod_errado;


			update trecterce						  
			set    cod_tercero = a_cod_correcto
			where  cod_tercero = a_cod_errado;

		end if
		
		let _cnt = 0;

		select count(*)
		into _cnt
		from trectrmae
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
			from  trectrmae
			where  cod_cliente = a_cod_errado;

			update trectrmae
			set cod_cliente = a_cod_correcto	  
			where cod_cliente = a_cod_errado;

		end if


		let _cnt = 0;

		select count(*)
		into _cnt
		from trectrmae
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
			from  trectrmae
			where  cod_proveedor = a_cod_errado;

			update trectrmae
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
		from twf_db_autos
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
			from  twf_db_autos
			where codcliente = a_cod_errado;


			update twf_db_autos
			set codcliente = a_cod_correcto	 
			where codcliente = a_cod_errado;

		end if

		let _cnt = 0;

		select count(*)
		into _cnt
		from twf_ordcomp
		where wf_proveedor = a_cod_errado;

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

			from  wf_ordcomp
			where  wf_proveedor = a_cod_errado;

			update twf_ordcomp					 
			set wf_proveedor = a_cod_correcto
			where wf_proveedor = a_cod_errado;

		end if
	   
		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcaspoliza
		 where cod_cliente = a_cod_errado;
			   
		if _cnt > 0 then

		insert into tmp_hijo
		select no_documento, cod_cliente, dia_cobros1, dia_cobros2, a_pagar, tipo_mov
		from tcaspoliza
		where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcaspoliza
		 where cod_cliente = a_cod_errado;
			   
		if _cnt > 0 then


		delete from tcaspoliza
	     where cod_cliente = a_cod_errado;

		end if

		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcascliente
		 where cod_cliente = a_cod_errado;
			   
		if _cnt > 0 then

		update tcascliente
		set cod_cliente = a_cod_correcto
		where cod_cliente = a_cod_errado; 

		end if

	   let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcascliente
		 where cod_cliente = a_cod_errado;
			   
		if _cnt > 0 then

		update tmp_hijo
		   set cod_cliente = a_cod_correcto
		 where cod_cliente = a_cod_errado;

		end if	
		{
		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcaspoliza
		 where cod_cliente = a_cod_errado;
			   
		if _cnt = 0 then


		insert into tcaspoliza
		select no_documento, cod_cliente, dia_cobros1, dia_cobros2, a_pagar, tipo_mov
		from tmp_hijo;

		end if
		}
	   --	drop table tmp_hijo;

		let _cnt = 0;
		select count(*)
		  into _cnt
		  from tcliclien
		 where cod_cliente = a_cod_errado;
			   
		if _cnt > 0 then
		
		delete from tcliclien
		where cod_cliente = a_cod_errado;

		end if
  	
   			-- end
	 		-- rollback work;
			-- return 0, "Actualizacion Exitosa";
	  		-- end procedure
-- end foreach

return 0, "Actualizacion Exitosa";

end procedure;

