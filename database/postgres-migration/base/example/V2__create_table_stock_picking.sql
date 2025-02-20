--
-- Name: stock_picking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_picking (
    id integer NOT NULL,
    backorder_id integer,
    return_id integer,
    group_id integer,
    location_id integer NOT NULL,
    location_dest_id integer NOT NULL,
    picking_type_id integer NOT NULL,
    partner_id integer,
    company_id integer,
    user_id integer,
    owner_id integer,
    create_uid integer,
    write_uid integer,
    name character varying,
    origin character varying,
    move_type character varying NOT NULL,
    state character varying,
    priority character varying,
    picking_properties jsonb,
    note text,
    has_deadline_issue boolean,
    printed boolean,
    is_locked boolean,
    scheduled_date timestamp without time zone,
    date_deadline timestamp without time zone,
    date timestamp without time zone,
    date_done timestamp without time zone,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    sale_id integer,
    carrier_id integer,
    carrier_tracking_ref character varying,
    weight numeric,
    carrier_price double precision
);


--
-- Name: TABLE stock_picking; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.stock_picking IS 'Transfer';


--
-- Name: COLUMN stock_picking.backorder_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.backorder_id IS 'Back Order of';


--
-- Name: COLUMN stock_picking.return_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.return_id IS 'Return of';


--
-- Name: COLUMN stock_picking.group_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.group_id IS 'Procurement Group';


--
-- Name: COLUMN stock_picking.location_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.location_id IS 'Source Location';


--
-- Name: COLUMN stock_picking.location_dest_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.location_dest_id IS 'Destination Location';


--
-- Name: COLUMN stock_picking.picking_type_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.picking_type_id IS 'Operation Type';


--
-- Name: COLUMN stock_picking.partner_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.partner_id IS 'Contact';


--
-- Name: COLUMN stock_picking.company_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.company_id IS 'Company';


--
-- Name: COLUMN stock_picking.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.user_id IS 'Responsible';


--
-- Name: COLUMN stock_picking.owner_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.owner_id IS 'Assign Owner';


--
-- Name: COLUMN stock_picking.create_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.create_uid IS 'Created by';


--
-- Name: COLUMN stock_picking.write_uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.write_uid IS 'Last Updated by';


--
-- Name: COLUMN stock_picking.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.name IS 'Reference';


--
-- Name: COLUMN stock_picking.origin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.origin IS 'Source Document';


--
-- Name: COLUMN stock_picking.move_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.move_type IS 'Shipping Policy';


--
-- Name: COLUMN stock_picking.state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.state IS 'Status';


--
-- Name: COLUMN stock_picking.priority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.priority IS 'Priority';


--
-- Name: COLUMN stock_picking.picking_properties; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.picking_properties IS 'Properties';


--
-- Name: COLUMN stock_picking.note; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.note IS 'Notes';


--
-- Name: COLUMN stock_picking.has_deadline_issue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.has_deadline_issue IS 'Is late';


--
-- Name: COLUMN stock_picking.printed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.printed IS 'Printed';


--
-- Name: COLUMN stock_picking.is_locked; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.is_locked IS 'Is Locked';


--
-- Name: COLUMN stock_picking.scheduled_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.scheduled_date IS 'Scheduled Date';


--
-- Name: COLUMN stock_picking.date_deadline; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.date_deadline IS 'Deadline';


--
-- Name: COLUMN stock_picking.date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.date IS 'Creation Date';


--
-- Name: COLUMN stock_picking.date_done; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.date_done IS 'Date of Transfer';


--
-- Name: COLUMN stock_picking.create_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.create_date IS 'Created on';


--
-- Name: COLUMN stock_picking.write_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.write_date IS 'Last Updated on';


--
-- Name: COLUMN stock_picking.carrier_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.carrier_id IS 'Carrier';


--
-- Name: COLUMN stock_picking.carrier_tracking_ref; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.carrier_tracking_ref IS 'Tracking Reference';


--
-- Name: COLUMN stock_picking.weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.weight IS 'Weight';


--
-- Name: COLUMN stock_picking.carrier_price; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.stock_picking.carrier_price IS 'Shipping Cost';

--
-- Name: stock_picking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_picking_id_seq OWNED BY public.stock_picking.id;